#include <stdlib.h>
#include <curl/curl.h>

#define CURL_HTTP_VERSION    CURLOPTTYPE_LONG + 84
#define CURL_HTTP_VERSION_3  30

const char *url_google = "http://google.com";
 
void get_google_homepage() {
   CURL *curl = curl_easy_init();
   curl_easy_setopt(curl, CURLOPT_URL, url_google);
   curl_easy_setopt(curl, CURL_HTTP_VERSION, CURL_HTTP_VERSION_3);
   curl_easy_perform(curl);
   curl_easy_cleanup(curl);
}

int main(int args, char* argv[]) {
   get_google_homepage();
   exit(0);
}

