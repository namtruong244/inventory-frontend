// Sinh email/mật khẩu duy nhất cho flow đăng ký qua UI (không gọi API).
output.email = 'e2e_' + new Date().getTime() + Math.floor(Math.random() * 1000) + '@test.local';
output.password = 'Passw0rd!123';
