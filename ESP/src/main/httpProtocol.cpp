#include <httpProtocol.h>

// GET request HTTP
String httpGETRequest(String serverName) {
  HTTPClient http;
    
  // Your IP address with path or Domain name with URL path 
  Serial.println(serverName);
  http.begin(serverName);
  
  // Send HTTP GET request
  int httpResponseCode = http.GET();
  
  String payload = "--"; 
  
  if (httpResponseCode>0) {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
    payload = http.getString();
  }
  else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
  }
  // Free resources
  http.end();

  return payload;
}

// POST request HTTP
String httpPOSTRequest(String serverName, String param) {
  HTTPClient http;
    
  // Your IP address with path or Domain name with URL path 
  Serial.println(serverName);
  
  http.begin(serverName);
  http.addHeader("Content-Type", "application/json");

  digitalWrite(5, HIGH);
  // Send HTTP POST request
  int httpResponseCode = http.POST(param);
  digitalWrite(5, LOW);

  Serial.println(param);
  
  String payload = "--"; 
  
  if (httpResponseCode>0) {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
    payload = http.getString();
  }
  else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
  }
  // Free resources
  http.end();

  return payload;
}