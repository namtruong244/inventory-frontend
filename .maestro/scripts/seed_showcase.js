// Tạo user "Minh" + dữ liệu mẫu giống bản thiết kế (chạy bằng runScript).
// Env: API_URL (mặc định http://localhost:8080).
// Kết quả: output.email, output.password, output.token.
var base = (typeof API_URL !== 'undefined' ? API_URL : 'http://localhost:8080') + '/api/v1';

function post(path, body, token) {
  var headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = 'Bearer ' + token;
  var res = http.post(base + path, { headers: headers, body: JSON.stringify(body) });
  if (!res.ok) throw new Error('POST ' + path + ' -> ' + res.status + ' ' + res.body);
  return JSON.parse(res.body).data;
}

function uuid() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    var r = (Math.random() * 16) | 0;
    return (c === 'x' ? r : (r & 3) | 8).toString(16);
  });
}

function daysFromNow(n) {
  return new Date(new Date().getTime() + n * 86400000).toISOString().substring(0, 10);
}

var stamp = new Date().getTime() + '' + Math.floor(Math.random() * 1000);
output.email = 'showcase_' + stamp + '@test.local';
output.password = 'Passw0rd!123';

var auth = post('/auth/register', { name: 'Minh', email: output.email, password: output.password });
var token = auth.token;
output.token = token;

// Danh mục phải tồn tại trước khi tạo item; bỏ qua lỗi nếu đã là danh mục mặc định.
['Electronics', 'Health', 'Games', 'Tools'].forEach(function (name) {
  http.post(base + '/categories', {
    headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + token },
    body: JSON.stringify({ name: name }),
  });
});

function box(name, type, parent) {
  var b = post('/boxes', {
    id: uuid(), name: name, type: type, parentId: parent || null,
    label: 'loc_' + uuid().substring(0, 8),
  }, token);
  return b.id;
}

function item(name, boxId, category, quantity, unit, extra) {
  var body = { id: uuid(), name: name, boxId: boxId, categoryId: category, quantity: quantity, unit: unit, status: 'stored' };
  for (var k in extra || {}) body[k] = extra[k];
  return post('/items', body, token).id;
}

var living = box('Living room', 'room');
var kitchen = box('Kitchen', 'room');
var bedroom = box('Bedroom', 'room');
var garage = box('Garage', 'room');

var cabinet = box('Oak cabinet', 'cabinet', living);
var topShelf = box('Top shelf', 'shelf', cabinet);
var cables = box('Cables & chargers', 'shelf', cabinet);
var bottomShelf = box('Bottom shelf', 'shelf', cabinet);
var tvDrawer = box('TV console drawer', 'drawer', living);
var games = box('Board games', 'box', living);

item('AA Batteries (Eneloop)', cables, 'Electronics', 4, 'pcs', { minQuantity: 8, isConsumable: true });
item('USB-C Cable 2m', cables, 'Electronics', 6, 'pcs', { minQuantity: 2 });
item('65W GaN Charger', cables, 'Electronics', 2, 'pcs', { minQuantity: 3, purchasePrice: 42, purchaseDate: daysFromNow(-120) });
item('Sony WH-1000XM4', topShelf, 'Electronics', 1, 'pcs', {
  purchasePrice: 279, purchaseDate: daysFromNow(-700), warrantyExpiryDate: daysFromNow(12), serialNumber: 'SN-WH1000XM4-2231',
});
item('Vitamin D3 2000IU', bottomShelf, 'Health', 30, 'pcs', { minQuantity: 10, expiryDate: daysFromNow(9) });
item('Catan', games, 'Games', 1, 'pcs', {});
item('HDMI Cable', tvDrawer, 'Electronics', 2, 'pcs', { minQuantity: 1 });
item('Remote Control', tvDrawer, 'Electronics', 1, 'pcs', {});
item('Cordless Screwdriver Set', garage, 'Tools', 1, 'set', {});
var drill = item('Bosch GSR 18V-55 cordless drill', garage, 'Tools', 1, 'pcs', {
  purchasePrice: 129, purchaseDate: daysFromNow(-400), warrantyExpiryDate: daysFromNow(330), serialNumber: 'GSR-18V55-0042',
  customAttributes: { Voltage: '18V', Brand: 'Bosch', Torque: '55 Nm' },
});
var projector = item('Mini Projector', living, 'Electronics', 1, 'pcs', { purchasePrice: 180 });

post('/lending/lend', {
  itemId: projector, borrowerName: 'Linh', borrowerContact: 'linh@example.com',
  lentDate: daysFromNow(-20) + 'T09:00:00.000Z', expectedReturnDate: daysFromNow(-5) + 'T18:00:00.000Z',
  notes: 'For movie night',
}, token);
output.drillId = drill;
