# Wireless Sensor Network

## I. Giới thiệu:

- Vi điều khiển sử dụng: ESP32 
- Công nghệ không dây sử dụng: Wifi
- Công nghệ nhận diện Wifi: Smart config ESPTouchV2
- Số node thí nghiệm: 4
- Diện tích phòng: 35m^2
- Vị trí đặt node: 4 góc phòng, có thể di chuyển
- Server, app đặt trên máy tính
- Data lưu tại Server
- Pin(Recommended): Pin Lipo 2100mAh

## II. Cài đặt
 
### Yêu cầu

- [Visual Studio](https://code.visualstudio.com/Download)
- [PlatformIO](https://platformio.org/install/ide?install=vscode) (hoặc Arduino IDE)
- [NodeJS](https://nodejs.org/en/download/)
- [Xcode](https://developer.apple.com/xcode/) (dành cho App)
- Esptouch trên điện thoại (đối với SmartConfig)

### Cài đặt gói

Mở terminal tại thư mục SERVER
```
$ npm install
```
Mở thư mục ESP bấm build hoặc nhấp vào biểu tượng con kiến bên trái, mở Miscellaneous, mở PlatformIO Core CLI
```
$ pio run
```
Mở terminal tại thư mục APP
```
$ pod install
```

## III. Mô tả hoạt động

### 1. Nhiệm vụ của Node

- Đo nhiệt độ, báo ngưỡng bằng led
- Gửi nhiệt độ lên server và lấy giá trị ngưỡng về

### 2. Lưu đồ thuật toán Node

- Kiểm tra cần smartconfig hay không nếu cần sẽ bỏ qua smartconfig nếu cần sẽ smartconfig -> chuyển sang chế độ ngủ ngắt ngoài -> ngủ chờ nhấn nút -> nhấn nút sẽ thức dậy chuyển sang chế độ ngủ timer -> ngủ chờ 14s -> thức dậy và đo -> đẩy giá trị đo lên server -> lấy giá trị ngưỡng của chính nó về và so sánh -> so sánh xong sẽ hiện đèn tương ứng và ngủ

### 3. Nhiệm vụ của Server

- Xử các request từ app UI và sensor nodes.
- Lưu trữ dữ liệu.

### 4. Lưu đồ thuật toán Server

- Ngôn ngữ lập trình: JavaScript.
- Enviroment: Node JS.
- Xử lí request tới 3 cổng định hướng: /espPost, /espGet, /espConfig.
- /espGet sẽ được gọi bởi App UI để lấy giá trị nhiệt độ của các node hoặc gọi bởi các node để lấy giá trị ngưỡng
- /espPost sẽ được gọi bởi App UI để đẩy giá trị ngưỡng lên của node chỉ định hoặc gọi bởi các node để đẩy giá trị nhiệt độ
- /espConfig: mỗi lần kết nối mạng Wi-Fi mới, sensor node request tới để kiểm tra xem địa chỉ server này có chính xác không.
- Bản tin request có thể chứa: value, nodeID, cờ báo setpoint, password.

### 5. Giải thích code Server

- index.js là file chính để khởi chạy server.
- ./server bao gồm 3 file: app.js (xử lí các request tới 3 cổng định hướng); data.json(lưu trữ giá trị cảm biến và setpoint)`host.js` (lấy IP của thiết bị đang deloy server, và port chỉ định mà server sẽ lắng nghe).
- 3 cổng định hướng bao gồm: /espGet, /espConfig, /espPost.
- Để giao tiếp với các cổng, các thiết bị sẽ phải request kèm với password
- /espConfig node gửi đến sẽ được xác nhận bằng password gửi về
- /espGet sẽ gửi về giá trị nếu thành công
- /espPost sẽ gửi về mô tả thay đổi nếu thành công

## IV. Thí nghiệm hoạt động: (Xem video)

- Ban đầu ta sẽ tiến hành bật Server, Server sẽ in ra địa chỉ đang hoạt động
- Các node sẽ ở trạng thái hoạt động vào thời điểm đầu tiên kể từ khi reset hoặc cấp nguồn và chờ smartconfig WiFi, ta sẽ dùng ứng dụng ESPTouch trên điện thoại để truyền SSID, Password và địa chỉ Server đang chạy cho các node, các node nhận đc thông tin sẽ confirm trở lại điện thoại bằng địa chỉ IP
- Sau khi nhận đc thông tin WiFi, các node sẽ tiến hành kiểm thử địa chỉ để xác nhận chính xác là Server của ta chứ không phải Server khác với mục đích tránh việc gửi nhầm địa chỉ, nếu sai đèn D2 sẽ nháy 1 lần ta sẽ phải reset để smartconfig lại, nếu đúng sẽ chuyển sang ngủ bằng EXT0 bằng nút nhấn. 
- Để bắt đầu đo ta nhấn nút và node sẽ thức dậy và chuyển sang trạng thái ngủ bằng timer trong 14s để cảm biến truyền nhiệt đủ, sau 14s node thức dậy và tiến hành quá trình đo.
- Sau khi đo xong các node tiến hành gửi dữ liệu lên Server bằng lệnh POST, thành công sẽ nháy đèn D2 2 lần và nhận về giá trị Setpoint
- Setpoint sẽ cập nhật và so sánh với giá trị hiện tại và hiện led tương ứng, hoàn thành sẽ chuyển sang trạng thái ngủ bằng EXT0 bằng nút nhấn và chờ lần nhấn tiếp theo.
- Giá trị của các node sẽ được hiển thị trên App, để thay đổi Setpoint ta sẽ sang tab Setpoint trên App để điều chỉnh. App sẽ POST Setpoint cần thay đổi lên Server và cập nhật.

## V. Đánh giá hiệu năng

- Để cảm biến truyền nhiệt đủ khi thay đổi môi trường đột ngột thì khi bấm nút sẽ phải chờ 14s để cảm biến truyền nhiệt đủ rồi mới đo
- Tổng thời gian đo: 14s ngủ và trung bình 4-6s hoạt động (bao gồm đo, đẩy dữ liệu, hiện ngưỡng)  
- Giả sử đo liên tục thì thời gian ngủ là 70% thời gian đo 30% điều này sẽ giúp tiết kiệm năng lượng khá tốt