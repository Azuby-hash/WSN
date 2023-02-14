#include <Arduino.h>
#include <WiFi.h>
#include <httpProtocol.h>
#include <smartConfig.h> 
#include <OneWire.h>
#include <DallasTemperature.h>

#define NODE_ID 1 // From 1 to n

unsigned long _time = 0;
unsigned long _time2 = 0;

// Config chế độ đọc tín hiệu 1 dây
OneWire oneWire(4);

// Tạo 1 handler đo thông qua dây đã config
DallasTemperature sensors(&oneWire);

// Biến lưu trữ nhiệt độ
float temperatureC = 0;

// Lý do đánh thức khỏi sleep
void print_wakeup_reason(){
  esp_sleep_wakeup_cause_t wakeup_reason;

  // Lấy lý do đánh thức
  wakeup_reason = esp_sleep_get_wakeup_cause();

  switch(wakeup_reason)
  {
    case ESP_SLEEP_WAKEUP_EXT0 : Serial.println("Wakeup caused by external signal using RTC_IO"); break;
    case ESP_SLEEP_WAKEUP_EXT1 : Serial.println("Wakeup caused by external signal using RTC_CNTL"); break;
    case ESP_SLEEP_WAKEUP_TIMER : Serial.println("Wakeup caused by timer"); break;
    case ESP_SLEEP_WAKEUP_TOUCHPAD : Serial.println("Wakeup caused by touchpad"); break;
    case ESP_SLEEP_WAKEUP_ULP : Serial.println("Wakeup caused by ULP program"); break;
    default : Serial.printf("Wakeup was not caused by deep sleep: %d\n",wakeup_reason); break;
  }
}

void setup() {
  Serial.begin(115200);

  // Đèn D2 sáng trong thời gian thức
  pinMode(2, OUTPUT);
  digitalWrite(2, HIGH);

  // In ra lý do thức dậy
  print_wakeup_reason();

  // Cài đặt thời gian ngủ
  esp_sleep_enable_timer_wakeup(6 * 1000000);

  // Smart config wifi và xác định địa chỉ IP của server
  wifiSmartConfig();

  // Đo nhiệt độ và lưu giá trị
  sensors.requestTemperatures(); 
  temperatureC = sensors.getTempCByIndex(0);
}

void loop() {
  if (millis() - _time > 1000) {
    _time = millis();

    // String request để đẩy giá trị lên server
    String reqString = "http://" + server + "/espPost";

    // JSON chứa index node hiện tại, giá trị và bảo mật cần gửi
    String json = "{\"number\":" + (String)NODE_ID + ",\"password\":\"9797964a-2f5c-41c6-91c1-44aa68308631\", \"value\":" ;
    json = json + temperatureC;
    json = json + "}";

    // Request post lên server
    String resString = httpPOSTRequest(reqString, json);

    // In ra response trả về từ server
    Serial.println(resString);

    // Xóa bộ nhớ và ngủ
    Serial.flush(); 
    esp_deep_sleep_start();
  }
}