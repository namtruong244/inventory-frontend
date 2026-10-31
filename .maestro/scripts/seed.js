// Gọi API backend trực tiếp để tạo dữ liệu nhanh cho flow (chạy bằng runScript).
// Env: API_URL (mặc định http://localhost:8080), SEED_ROOMS (số phòng tạo sẵn, mặc định 0).
// Kết quả: output.email, output.password, output.token, output.roomId, output.roomLabel.
var base = (typeof API_URL !== 'undefined' ? API_URL : 'http://localhost:8080') + '/api/v1';
var json = { 'Content-Type': 'application/json' };

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

var stamp = new Date().getTime() + '' + Math.floor(Math.random() * 1000);
output.email = 'e2e_' + stamp + '@test.local';
output.password = 'Passw0rd!123';

var auth = post('/auth/register', {
  name: 'E2E User',
  email: output.email,
  password: output.password,
});
output.token = auth.token;

var rooms = typeof SEED_ROOMS !== 'undefined' ? parseInt(SEED_ROOMS, 10) : 0;
for (var i = 0; i < rooms; i++) {
  var room = post('/boxes', { id: uuid(), name: 'Room ' + (i + 1), type: 'room', label: 'loc_' + uuid().substring(0, 8) }, output.token);
  if (i === 0) {
    output.roomId = room.id;
    output.roomLabel = room.label;
  }
}
