#include <Arduino.h>
#include <WiFi.h>
#include <httpProtocol.h>
#include <smartConfig.h> 
#include <OneWire.h>
#include <DallasTemperature.h>
#include <ArduinoJson.h>

#define NODE_ID 1 // From 1 to n

unsigned long _time = 0;
unsigned long _time2 = 0;

// Config chế độ đọc tín hiệu 1 dây
OneWire oneWire(4);

// Tạo 1 handler đo thông qua dây đã config
DallasTemperature sensors(&oneWire);

// Doc parse json thành object
DynamicJsonDocument doc(1024);

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

void ledEnableHoldState() {
  gpio_hold_en(GPIO_NUM_25);
  gpio_hold_en(GPIO_NUM_26);
  gpio_hold_en(GPIO_NUM_27);
}

void ledDisableHoldState() {
  gpio_hold_dis(GPIO_NUM_25);
  gpio_hold_dis(GPIO_NUM_26);
  gpio_hold_dis(GPIO_NUM_27);
}

void setup() {
  Serial.begin(115200);

  pinMode(25, OUTPUT);
  pinMode(26, OUTPUT);
  pinMode(27, OUTPUT);
  pinMode(5, OUTPUT);
  digitalWrite(5, LOW);

  // Đèn D2 sáng trong thời gian thức
  pinMode(2, OUTPUT);
  digitalWrite(2, HIGH);

  pinMode(0, INPUT_PULLUP);

  // In ra lý do thức dậy
  print_wakeup_reason();

  // Cài đặt thời gian ngủ
  esp_sleep_disable_wakeup_source(ESP_SLEEP_WAKEUP_EXT0);
  esp_sleep_enable_timer_wakeup(6 * 1000000);

  // Smart config wifi và xác định địa chỉ IP của server
  wifiSmartConfig();
}

void loop() {
  if (digitalRead(0) == LOW) {
    delay(50);

    while (digitalRead(0) == LOW);

    esp_sleep_enable_ext0_wakeup(GPIO_NUM_0, 0);
    esp_sleep_disable_wakeup_source(ESP_SLEEP_WAKEUP_TIMER);

    Serial.flush(); 
    esp_deep_sleep_start();
  }
  if (millis() - _time > 500) {
    _time = millis();

    // Đo nhiệt độ và lưu giá trị
    sensors.requestTemperatures(); 
    temperatureC = sensors.getTempCByIndex(0);
    if (temperatureC < 0.1) { 
      return;
    }

    // String request để đẩy giá trị lên server ------------------------------
    String reqString1 = "http://" + server + "/espPost";

    // JSON chứa index node hiện tại, giá trị và bảo mật cần gửi
    String json1 = "{\"number\":" + (String)NODE_ID + ",\"password\":\"9797964a-2f5c-41c6-91c1-44aa68308631\", \"value\":" ;
    json1 = json1 + temperatureC;
    json1 = json1 + "}";

    // Request post lên server
    String resString1 = httpPOSTRequest(reqString1, json1);

    // In ra response trả về từ server
    Serial.println(resString1);

    // String request để lấy giá trị từ server -------------------------------
    String reqString2 = "http://" + server + "/espGet";

    // JSON chứa bảo mật cần gửi
    String json2 = "{\"number\":" + (String)NODE_ID + ",\"password\":\"9797964a-2f5c-41c6-91c1-44aa68308631\", \"isSP\": true}" ;

    // Request post lên server
    String resString2 = httpPOSTRequest(reqString2, json2);
    
    // Response trả về setpoint, convert ra float
    deserializeJson(doc, resString2);
    float sp = doc.as<float>();

    ledDisableHoldState();

    // So sánh với giá trị hiện tại
    if (sp <= temperatureC) {
      digitalWrite(25, HIGH);
      digitalWrite(26, LOW);
      digitalWrite(27, LOW);
    }

    if (sp > temperatureC && (sp - temperatureC) < 10) {
      digitalWrite(25, LOW);
      digitalWrite(26, HIGH);
      digitalWrite(27, LOW);
    }

    if (sp > temperatureC && (sp - temperatureC) < 20) {
      digitalWrite(25, LOW);
      digitalWrite(26, LOW);
      digitalWrite(27, HIGH);
    }

    // In ra response trả về từ server
    Serial.println(resString2);

    // Xóa bộ nhớ và ngủ
    Serial.flush(); 
    ledEnableHoldState();
    esp_deep_sleep_start();
  }
}