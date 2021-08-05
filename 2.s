.intel_syntax noprefix

.include "std.macro"
.include "curl.const"

  .section .data
curl:       .quad 0

  .section .rodata
url_google: .asciz "http://google.com"

  .section .text
get_google_homepage: push rsp
  λ curl_easy_init    ; → [curl]
  α rdx, [url_google] ; λ curl_easy_setopt, rax, CURLOPT_URL
  α rdi, [curl]       ; λ curl_easy_setopt, _, CURL_HTTP_VERSION, CURL_HTTP_VERSION_3
  λ curl_easy_perform, [curl]
  λ curl_easy_cleanup, [curl]
  pop rsp ; ret

  .global main
main: push rax
  λ get_google_homepage
  λ exit, 0

