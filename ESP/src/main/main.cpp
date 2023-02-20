#include <Arduino.h>
#include <WiFi.h>
#include <httpProtocol.h>
#include <smartConfig.h> 
#include <OneWire.h>
#include <DallasTemperature.h>
#include <ArduinoJson.h>
#include <main.h>

#define NODE_ID 1 // From 1 to n
#define SLEEP_TIME_MEASURE 14

unsigned long _time = 0;
unsigned long _time2 = 0;

RTC_DATA_ATTR float sp = 0;

enum STATE {
  STATE_DISABLE, STATE_CLICK, STATE_ENABLE
};

RTC_DATA_ATTR bool _isFirstTime = true;
RTC_DATA_ATTR STATE _state = STATE_DISABLE; 
/**
 * STATE_DISABLE: chưa nhấn nút, chưa đợi cảm biến nóng
 * STATE_CLICK: đã nhấn nút, chưa đợi cảm biến nóng
 * STATE_ENABLE: đã nhấn nút, cảm biến đủ nóng (sau 14s)
*/

// Config chế độ đọc tín hiệu 1 dây
OneWire oneWire(4);

// Tạo 1 handler đo thông qua dây đã config
DallasTemperature sensors(&oneWire);

// Parse json thành object
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
  // Bật khóa trạng thái led

  gpio_hold_en(LED_SP_NORMAL);
  gpio_hold_en(LED_SP_MEDIUM);
  gpio_hold_en(LED_SP_HIGH);
}

void ledDisableHoldState() {
  // Tắt khóa trạng thái led

  gpio_hold_dis(LED_SP_NORMAL);
  gpio_hold_dis(LED_SP_MEDIUM);
  gpio_hold_dis(LED_SP_HIGH);
}

void setup() {
  Serial.begin(115200);

  // Đèn D2 sáng trong thời gian thức
  pinMode(LED_ON_ACTIVE, OUTPUT);
  pinMode(LED_SP_NORMAL, OUTPUT);
  pinMode(LED_SP_MEDIUM, OUTPUT);
  pinMode(LED_SP_HIGH, OUTPUT);
  pinMode(LED_ON_REQUEST, OUTPUT);
  digitalWrite(LED_ON_REQUEST, LOW);

  pinMode(BUTTON_MEASURE, INPUT_PULLUP);
  digitalWrite(LED_ON_ACTIVE, HIGH);

  // In ra lý do thức dậy
  print_wakeup_reason();

  Serial.println(_state);

  if (_state == STATE_DISABLE) {
    if (_isFirstTime) {
      // Smart config trc khi ngủ

      _isFirstTime = false;
      wifiSmartConfig();
    }

    esp_sleep_enable_ext0_wakeup(BUTTON_MEASURE, 0);
    esp_sleep_disable_wakeup_source(ESP_SLEEP_WAKEUP_TIMER);

    _state = STATE_CLICK;
    Serial.flush(); 
    ledEnableHoldState();
    esp_deep_sleep_start();
    return;
  }

  if (_state == STATE_CLICK) {
    // Cài đặt thời gian ngủ
    esp_sleep_enable_timer_wakeup(SLEEP_TIME_MEASURE * 1000000);
    esp_sleep_disable_wakeup_source(ESP_SLEEP_WAKEUP_EXT0);

    _state = STATE_ENABLE;
    Serial.flush(); 
    ledEnableHoldState();
    esp_deep_sleep_start();
  }

  // Smart config wifi và xác định địa chỉ IP của server
  wifiSmartConfig();
}

void loop() {
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
    String json1 = "{\"number\":" + (String)NODE_ID + ",\"password\":\"" + serverPassword + "\", \"value\":" ;
    json1 = json1 + temperatureC;
    json1 = json1 + "}";

    // Request post lên server
    String resString1 = httpPOSTRequest(reqString1, json1);

    // In ra response trả về từ server
    Serial.println(resString1);

    // String request để lấy set point từ server -------------------------------
    String reqString2 = "http://" + server + "/espGet";

    // JSON chứa bảo mật cần gửi
    String json2 = "{\"number\":" + (String)NODE_ID + ",\"password\":\"" + serverPassword + "\", \"isSP\": true}" ;

    // Request post lên server
    String resString2 = httpPOSTRequest(reqString2, json2);
    
    // Response trả về setpoint, convert ra float
    deserializeJson(doc, resString2);
    sp = doc.as<float>();

    ledDisableHoldState();

    Serial.println(sp);

    // So sánh với giá trị hiện tại
    if (sp <= temperatureC) {
      digitalWrite(LED_SP_NORMAL, LOW);
      digitalWrite(LED_SP_MEDIUM, LOW);
      digitalWrite(LED_SP_HIGH, HIGH);
    }

    if (sp > temperatureC && (sp - temperatureC) < 10) {
      digitalWrite(LED_SP_NORMAL, LOW);
      digitalWrite(LED_SP_MEDIUM, HIGH);
      digitalWrite(LED_SP_HIGH, LOW);
    }

    if (sp > temperatureC && (sp - temperatureC) >= 10) {
      digitalWrite(LED_SP_NORMAL, HIGH);
      digitalWrite(LED_SP_MEDIUM, LOW);
      digitalWrite(LED_SP_HIGH, LOW);
    }

    // In ra response trả về từ server
    Serial.println(resString2);

    // Xóa bộ nhớ và ngủ
    esp_sleep_enable_ext0_wakeup(BUTTON_MEASURE, 1);
    esp_sleep_disable_wakeup_source(ESP_SLEEP_WAKEUP_TIMER);

    _state = STATE_DISABLE;
    Serial.flush(); 
    ledEnableHoldState();
    esp_deep_sleep_start();
  }
}