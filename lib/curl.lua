--[=========================================================================[
  |                                  _   _ ____  _
  |  Project                     ___| | | |  _ \| |
  |                             / __| | | | |_) | |
  |                            | (__| |_| |  _ <| |___
  |                             \___|\___/|_| \_\_____|
  |
  | COPYRIGHT AND PERMISSION NOTICE
  | 
  | Copyright (c) 1996 - 2014, Daniel Stenberg, daniel@haxx.se.
  | Copyright luajit port (C) 2014 Andreas Bosch, code@progandy.de
  | 
  | All rights reserved.
  | 
  | Permission to use, copy, modify, and distribute this software for any
  | purpose with or without fee is hereby granted, provided that the above
  | copyright notice and this permission notice appear in all copies.
  | 
  | THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
  | EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
  | MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT 
  | OF THIRD PARTY RIGHTS. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
  | HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
  | IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
  | IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
  | SOFTWARE.
  | 
  | Except as contained in this notice, the name of a copyright holder 
  | shall not be used in advertising or otherwise to promote the sale, use
  | or other dealings in this Software without prior written authorization
  | of the copyright holder.
  | 
  | -----------------------------------------------------------------------
  | 
  | This is a clean port of the original curl headers to luajit ffi
  | 
--]=========================================================================]
local ffi = require("ffi")
_a=ffi.load("crypto")
_b=ffi.load("ssl")
local lib = ffi.load("curl")
local bit = require("bit")

local M = {}
setmetatable(M, { __index = lib })


ffi.cdef[[
 typedef struct {
    int64_t __fds_bits[1024 / 64];
  } curl_fd_set;
]]

-- curlver.h [[
M.LIBCURL_COPYRIGHT = "1996 - 2014 Daniel Stenberg, <daniel@haxx.se>."
M.LIBCURL_VERSION = "7.38.0"
M.LIBCURL_VERSION_MAJOR = 7
M.LIBCURL_VERSION_MINOR = 38
M.LIBCURL_VERSION_PATCH = 0
M.LIBCURL_VERSION_NUM = 0x072600
M.LIBCURL_TIMESTAMP = "Wed Sep 10 06:19:50 UTC 2014"
-- ]> curlver.h

-- curlbuild.h (32 and 64)
ffi.cdef[[
  typedef int64_t curl_off_t;
  typedef unsigned int curl_socklen_t;
  static const int CURL_SOCKET_BAD = -1;
  typedef intptr_t curl_time_t;
]]

-- curl.h [[
ffi.cdef[[
typedef struct {char __private;} CURL;
typedef int curl_socket_t;
static const int HTTPPOST_FILENAME = (1<<0);
static const int HTTPPOST_READFILE = (1<<1);
static const int HTTPPOST_PTRNAME = (1<<2);
static const int HTTPPOST_PTRCONTENTS = (1<<3);
static const int HTTPPOST_BUFFER = (1<<4);
static const int HTTPPOST_PTRBUFFER = (1<<5);
static const int HTTPPOST_CALLBACK = (1<<6);
struct curl_httppost {
  struct curl_httppost *next;
  char *name;
  long namelength;
  char *contents;
  long contentslength;
  char *buffer;
  long bufferlength;
  char *contenttype;
  struct curl_slist* contentheader;
  struct curl_httppost *more;
  long flags;
  char *showfilename;
  void *userp;
};
typedef int (*curl_progress_callback)(void *clientp,
                                      double dltotal,
                                      double dlnow,
                                      double ultotal,
                                      double ulnow);
typedef int (*curl_xferinfo_callback)(void *clientp,
                                      curl_off_t dltotal,
                                      curl_off_t dlnow,
                                      curl_off_t ultotal,
                                      curl_off_t ulnow);
static const int CURL_MAX_WRITE_SIZE = 16384;
static const int CURL_MAX_HTTP_HEADER = (100*1024);
static const int CURL_WRITEFUNC_PAUSE = 0x10000001;
typedef size_t (*curl_write_callback)(char *buffer,
                                      size_t size,
                                      size_t nitems,
                                      void *outstream);
typedef enum {
  CURLFILETYPE_FILE = 0,
  CURLFILETYPE_DIRECTORY,
  CURLFILETYPE_SYMLINK,
  CURLFILETYPE_DEVICE_BLOCK,
  CURLFILETYPE_DEVICE_CHAR,
  CURLFILETYPE_NAMEDPIPE,
  CURLFILETYPE_SOCKET,
  CURLFILETYPE_DOOR,
  CURLFILETYPE_UNKNOWN
} curlfiletype;
static const int CURLFINFOFLAG_KNOWN_FILENAME    = (1<<0);
static const int CURLFINFOFLAG_KNOWN_FILETYPE    = (1<<1);
static const int CURLFINFOFLAG_KNOWN_TIME        = (1<<2);
static const int CURLFINFOFLAG_KNOWN_PERM        = (1<<3);
static const int CURLFINFOFLAG_KNOWN_UID         = (1<<4);
static const int CURLFINFOFLAG_KNOWN_GID         = (1<<5);
static const int CURLFINFOFLAG_KNOWN_SIZE        = (1<<6);
static const int CURLFINFOFLAG_KNOWN_HLINKCOUNT  = (1<<7);
struct curl_fileinfo {
  char *filename;
  curlfiletype filetype;
  curl_time_t time;
  unsigned int perm;
  int uid;
  int gid;
  curl_off_t size;
  long int hardlinks;
  struct {
    char *time;
    char *perm;
    char *user;
    char *group;
    char *target;
  } strings;
  unsigned int flags;
  char * b_data;
  size_t b_size;
  size_t b_used;
};
static const int CURL_CHUNK_BGN_FUNC_OK      = 0;
static const int CURL_CHUNK_BGN_FUNC_FAIL    = 1;
static const int CURL_CHUNK_BGN_FUNC_SKIP    = 2;
typedef long (*curl_chunk_bgn_callback)(const void *transfer_info,
                                        void *ptr,
                                        int remains);
static const int CURL_CHUNK_END_FUNC_OK      = 0;
static const int CURL_CHUNK_END_FUNC_FAIL    = 1;
typedef long (*curl_chunk_end_callback)(void *ptr);
static const int CURL_FNMATCHFUNC_MATCH    = 0;
static const int CURL_FNMATCHFUNC_NOMATCH  = 1;
static const int CURL_FNMATCHFUNC_FAIL     = 2;
typedef int (*curl_fnmatch_callback)(void *ptr,
                                     const char *pattern,
                                     const char *string);
static const int CURL_SEEKFUNC_OK       = 0;
static const int CURL_SEEKFUNC_FAIL     = 1;
static const int CURL_SEEKFUNC_CANTSEEK = 2;
typedef int (*curl_seek_callback)(void *instream,
                                  curl_off_t offset,
                                  int origin);
static const int CURL_READFUNC_ABORT = 0x10000000;
static const int CURL_READFUNC_PAUSE = 0x10000001;
typedef size_t (*curl_read_callback)(char *buffer,
                                      size_t size,
                                      size_t nitems,
                                      void *instream);
typedef enum  {
  CURLSOCKTYPE_IPCXN,
  CURLSOCKTYPE_ACCEPT,
  CURLSOCKTYPE_LAST
} curlsocktype;
static const int CURL_SOCKOPT_OK = 0;
static const int CURL_SOCKOPT_ERROR = 1;
static const int CURL_SOCKOPT_ALREADY_CONNECTED = 2;
typedef int (*curl_sockopt_callback)(void *clientp,
                                     curl_socket_t curlfd,
                                     curlsocktype purpose);
struct curl_sockaddr {
  int family;
  int socktype;
  int protocol;
  unsigned int addrlen;
  struct {
    unsigned short int sa_family;
    char sa_data[14];
  } addr;
};
typedef curl_socket_t
(*curl_opensocket_callback)(void *clientp,
                            curlsocktype purpose,
                            struct curl_sockaddr *address);
typedef int
(*curl_closesocket_callback)(void *clientp, curl_socket_t item);
typedef enum {
  CURLIOE_OK,
  CURLIOE_UNKNOWNCMD,
  CURLIOE_FAILRESTART,
  CURLIOE_LAST
} curlioerr;
typedef enum  {
  CURLIOCMD_NOP,
  CURLIOCMD_RESTARTREAD,
  CURLIOCMD_LAST
} curliocmd;
typedef curlioerr (*curl_ioctl_callback)(CURL *handle,
                                         int cmd,
                                         void *clientp);
typedef void *(*curl_malloc_callback)(size_t size);
typedef void (*curl_free_callback)(void *ptr);
typedef void *(*curl_realloc_callback)(void *ptr, size_t size);
typedef char *(*curl_strdup_callback)(const char *str);
typedef void *(*curl_calloc_callback)(size_t nmemb, size_t size);
typedef enum {
  CURLINFO_TEXT = 0,
  CURLINFO_HEADER_IN,
  CURLINFO_HEADER_OUT,
  CURLINFO_DATA_IN,
  CURLINFO_DATA_OUT,
  CURLINFO_SSL_DATA_IN,
  CURLINFO_SSL_DATA_OUT,
  CURLINFO_END
} curl_infotype;
typedef int (*curl_debug_callback)
       (CURL *handle,
        curl_infotype type,
        char *data,
        size_t size,
        void *userptr);
typedef enum {
  CURLE_OK = 0,
  CURLE_UNSUPPORTED_PROTOCOL,
  CURLE_FAILED_INIT,
  CURLE_URL_MALFORMAT,
  CURLE_NOT_BUILT_IN,
  CURLE_COULDNT_RESOLVE_PROXY,
  CURLE_COULDNT_RESOLVE_HOST,
  CURLE_COULDNT_CONNECT,
  CURLE_FTP_WEIRD_SERVER_REPLY,
  CURLE_REMOTE_ACCESS_DENIED,
  CURLE_FTP_ACCEPT_FAILED,
  CURLE_FTP_WEIRD_PASS_REPLY,
  CURLE_FTP_ACCEPT_TIMEOUT,
  CURLE_FTP_WEIRD_PASV_REPLY,
  CURLE_FTP_WEIRD_227_FORMAT,
  CURLE_FTP_CANT_GET_HOST,
  CURLE_HTTP2,
  CURLE_FTP_COULDNT_SET_TYPE,
  CURLE_PARTIAL_FILE,
  CURLE_FTP_COULDNT_RETR_FILE,
  CURLE_OBSOLETE20,
  CURLE_QUOTE_ERROR,
  CURLE_HTTP_RETURNED_ERROR,
  CURLE_WRITE_ERROR,
  CURLE_OBSOLETE24,
  CURLE_UPLOAD_FAILED,
  CURLE_READ_ERROR,
  CURLE_OUT_OF_MEMORY,
  CURLE_OPERATION_TIMEDOUT,
  CURLE_OBSOLETE29,
  CURLE_FTP_PORT_FAILED,
  CURLE_FTP_COULDNT_USE_REST,
  CURLE_OBSOLETE32,
  CURLE_RANGE_ERROR,
  CURLE_HTTP_POST_ERROR,
  CURLE_SSL_CONNECT_ERROR,
  CURLE_BAD_DOWNLOAD_RESUME,
  CURLE_FILE_COULDNT_READ_FILE,
  CURLE_LDAP_CANNOT_BIND,
  CURLE_LDAP_SEARCH_FAILED,
  CURLE_OBSOLETE40,
  CURLE_FUNCTION_NOT_FOUND,
  CURLE_ABORTED_BY_CALLBACK,
  CURLE_BAD_FUNCTION_ARGUMENT,
  CURLE_OBSOLETE44,
  CURLE_INTERFACE_FAILED,
  CURLE_OBSOLETE46,
  CURLE_TOO_MANY_REDIRECTS ,
  CURLE_UNKNOWN_OPTION,
  CURLE_TELNET_OPTION_SYNTAX ,
  CURLE_OBSOLETE50,
  CURLE_PEER_FAILED_VERIFICATION,
  CURLE_GOT_NOTHING,
  CURLE_SSL_ENGINE_NOTFOUND,
  CURLE_SSL_ENGINE_SETFAILED,
  CURLE_SEND_ERROR,
  CURLE_RECV_ERROR,
  CURLE_OBSOLETE57,
  CURLE_SSL_CERTPROBLEM,
  CURLE_SSL_CIPHER,
  CURLE_SSL_CACERT,
  CURLE_BAD_CONTENT_ENCODING,
  CURLE_LDAP_INVALID_URL,
  CURLE_FILESIZE_EXCEEDED,
  CURLE_USE_SSL_FAILED,
  CURLE_SEND_FAIL_REWIND,
  CURLE_SSL_ENGINE_INITFAILED,
  CURLE_LOGIN_DENIED,
  CURLE_TFTP_NOTFOUND,
  CURLE_TFTP_PERM,
  CURLE_REMOTE_DISK_FULL,
  CURLE_TFTP_ILLEGAL,
  CURLE_TFTP_UNKNOWNID,
  CURLE_REMOTE_FILE_EXISTS,
  CURLE_TFTP_NOSUCHUSER,
  CURLE_CONV_FAILED,
  CURLE_CONV_REQD,
  CURLE_SSL_CACERT_BADFILE,
  CURLE_REMOTE_FILE_NOT_FOUND,
  CURLE_SSH,
  CURLE_SSL_SHUTDOWN_FAILED,
  CURLE_AGAIN,
  CURLE_SSL_CRL_BADFILE,
  CURLE_SSL_ISSUER_ERROR,
  CURLE_FTP_PRET_FAILED,
  CURLE_RTSP_CSEQ_ERROR,
  CURLE_RTSP_SESSION_ERROR,
  CURLE_FTP_BAD_FILE_LIST,
  CURLE_CHUNK_FAILED,
  CURLE_NO_CONNECTION_AVAILABLE,
  CURL_LAST
} CURLcode;
typedef CURLcode (*curl_conv_callback)(char *buffer, size_t length);
typedef CURLcode (*curl_ssl_ctx_callback)(CURL *curl,
                                          void *ssl_ctx,
                                          void *userptr);
typedef enum {
  CURLPROXY_HTTP = 0,
  CURLPROXY_HTTP_1_0 = 1,
  CURLPROXY_SOCKS4 = 4,
  CURLPROXY_SOCKS5 = 5,
  CURLPROXY_SOCKS4A = 6,
  CURLPROXY_SOCKS5_HOSTNAME = 7
} curl_proxytype;
static const unsigned int CURLAUTH_NONE         = ((unsigned int)0);
static const unsigned int CURLAUTH_BASIC        = (((unsigned int)1)<<0);
static const unsigned int CURLAUTH_DIGEST       = (((unsigned int)1)<<1);
static const unsigned int CURLAUTH_NEGOTIATE    = (((unsigned int)1)<<2);
static const unsigned int CURLAUTH_GSSNEGOTIATE = CURLAUTH_NEGOTIATE;
static const unsigned int CURLAUTH_NTLM         = (((unsigned int)1)<<3);
static const unsigned int CURLAUTH_DIGEST_IE    = (((unsigned int)1)<<4);
static const unsigned int CURLAUTH_NTLM_WB      = (((unsigned int)1)<<5);
static const unsigned int CURLAUTH_ONLY         = (((unsigned int)1)<<31);
static const unsigned int CURLAUTH_ANY          = (~CURLAUTH_DIGEST_IE);
static const unsigned int CURLAUTH_ANYSAFE      = (~(CURLAUTH_BASIC|CURLAUTH_DIGEST_IE));
static const int CURLSSH_AUTH_ANY       = ~0;
static const int CURLSSH_AUTH_NONE      = 0;
static const int CURLSSH_AUTH_PUBLICKEY = (1<<0);
static const int CURLSSH_AUTH_PASSWORD  = (1<<1);
static const int CURLSSH_AUTH_HOST      = (1<<2);
static const int CURLSSH_AUTH_KEYBOARD  = (1<<3);
static const int CURLSSH_AUTH_AGENT     = (1<<4);
static const int CURLSSH_AUTH_DEFAULT = CURLSSH_AUTH_ANY;
static const int CURLGSSAPI_DELEGATION_NONE        = 0;
static const int CURLGSSAPI_DELEGATION_POLICY_FLAG = (1<<0);
static const int CURLGSSAPI_DELEGATION_FLAG        = (1<<1);
static const int CURL_ERROR_SIZE = 256;
enum curl_khtype {
  CURLKHTYPE_UNKNOWN,
  CURLKHTYPE_RSA1,
  CURLKHTYPE_RSA,
  CURLKHTYPE_DSS
};
struct curl_khkey {
  const char *key;
  size_t len;
  enum curl_khtype keytype;
};
enum curl_khstat {
  CURLKHSTAT_FINE_ADD_TO_FILE,
  CURLKHSTAT_FINE,
  CURLKHSTAT_REJECT,
  CURLKHSTAT_DEFER,
  CURLKHSTAT_LAST
};
enum curl_khmatch {
  CURLKHMATCH_OK,
  CURLKHMATCH_MISMATCH,
  CURLKHMATCH_MISSING,
  CURLKHMATCH_LAST
};
typedef int
  (*curl_sshkeycallback) (CURL *easy,
                          const struct curl_khkey *knownkey,
                          const struct curl_khkey *foundkey,
                          enum curl_khmatch,
                          void *clientp);
typedef enum {
  CURLUSESSL_NONE,
  CURLUSESSL_TRY,
  CURLUSESSL_CONTROL,
  CURLUSESSL_ALL,
  CURLUSESSL_LAST
} curl_usessl;
static const int CURLSSLOPT_ALLOW_BEAST = (1<<0);
typedef enum {
  CURLFTPSSL_CCC_NONE,
  CURLFTPSSL_CCC_PASSIVE,
  CURLFTPSSL_CCC_ACTIVE,
  CURLFTPSSL_CCC_LAST
} curl_ftpccc;
typedef enum {
  CURLFTPAUTH_DEFAULT,
  CURLFTPAUTH_SSL,
  CURLFTPAUTH_TLS,
  CURLFTPAUTH_LAST
} curl_ftpauth;
typedef enum {
  CURLFTP_CREATE_DIR_NONE,
  CURLFTP_CREATE_DIR,
  CURLFTP_CREATE_DIR_RETRY,
  CURLFTP_CREATE_DIR_LAST
} curl_ftpcreatedir;
typedef enum {
  CURLFTPMETHOD_DEFAULT,
  CURLFTPMETHOD_MULTICWD,
  CURLFTPMETHOD_NOCWD,
  CURLFTPMETHOD_SINGLECWD,
  CURLFTPMETHOD_LAST
} curl_ftpmethod;
static const int CURLHEADER_UNIFIED  = 0;
static const int CURLHEADER_SEPARATE = (1<<0);
static const int CURLPROTO_HTTP   = (1<<0);
static const int CURLPROTO_HTTPS  = (1<<1);
static const int CURLPROTO_FTP    = (1<<2);
static const int CURLPROTO_FTPS   = (1<<3);
static const int CURLPROTO_SCP    = (1<<4);
static const int CURLPROTO_SFTP   = (1<<5);
static const int CURLPROTO_TELNET = (1<<6);
static const int CURLPROTO_LDAP   = (1<<7);
static const int CURLPROTO_LDAPS  = (1<<8);
static const int CURLPROTO_DICT   = (1<<9);
static const int CURLPROTO_FILE   = (1<<10);
static const int CURLPROTO_TFTP   = (1<<11);
static const int CURLPROTO_IMAP   = (1<<12);
static const int CURLPROTO_IMAPS  = (1<<13);
static const int CURLPROTO_POP3   = (1<<14);
static const int CURLPROTO_POP3S  = (1<<15);
static const int CURLPROTO_SMTP   = (1<<16);
static const int CURLPROTO_SMTPS  = (1<<17);
static const int CURLPROTO_RTSP   = (1<<18);
static const int CURLPROTO_RTMP   = (1<<19);
static const int CURLPROTO_RTMPT  = (1<<20);
static const int CURLPROTO_RTMPE  = (1<<21);
static const int CURLPROTO_RTMPTE = (1<<22);
static const int CURLPROTO_RTMPS  = (1<<23);
static const int CURLPROTO_RTMPTS = (1<<24);
static const int CURLPROTO_GOPHER = (1<<25);
static const int CURLPROTO_ALL    = (~0);
static const int CURLOPTTYPE_LONG          = 0;
static const int CURLOPTTYPE_OBJECTPOINT   = 10000;
static const int CURLOPTTYPE_FUNCTIONPOINT = 20000;
static const int CURLOPTTYPE_OFF_T         = 30000;
typedef enum {
  CURLOPT_WRITEDATA = CURLOPTTYPE_OBJECTPOINT + 1,
  CURLOPT_URL = CURLOPTTYPE_OBJECTPOINT + 2,
  CURLOPT_PORT = CURLOPTTYPE_LONG + 3,
  CURLOPT_PROXY = CURLOPTTYPE_OBJECTPOINT + 4,
  CURLOPT_USERPWD = CURLOPTTYPE_OBJECTPOINT + 5,
  CURLOPT_PROXYUSERPWD = CURLOPTTYPE_OBJECTPOINT + 6,
  CURLOPT_RANGE = CURLOPTTYPE_OBJECTPOINT + 7,
  CURLOPT_READDATA = CURLOPTTYPE_OBJECTPOINT + 9,
  CURLOPT_ERRORBUFFER = CURLOPTTYPE_OBJECTPOINT + 10,
  CURLOPT_WRITEFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 11,
  CURLOPT_READFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 12,
  CURLOPT_TIMEOUT = CURLOPTTYPE_LONG + 13,
  CURLOPT_INFILESIZE = CURLOPTTYPE_LONG + 14,
  CURLOPT_POSTFIELDS = CURLOPTTYPE_OBJECTPOINT + 15,
  CURLOPT_REFERER = CURLOPTTYPE_OBJECTPOINT + 16,
  CURLOPT_FTPPORT = CURLOPTTYPE_OBJECTPOINT + 17,
  CURLOPT_USERAGENT = CURLOPTTYPE_OBJECTPOINT + 18,
  CURLOPT_LOW_SPEED_LIMIT = CURLOPTTYPE_LONG + 19,
  CURLOPT_LOW_SPEED_TIME = CURLOPTTYPE_LONG + 20,
  CURLOPT_RESUME_FROM = CURLOPTTYPE_LONG + 21,
  CURLOPT_COOKIE = CURLOPTTYPE_OBJECTPOINT + 22,
  CURLOPT_HTTPHEADER = CURLOPTTYPE_OBJECTPOINT + 23,
  CURLOPT_HTTPPOST = CURLOPTTYPE_OBJECTPOINT + 24,
  CURLOPT_SSLCERT = CURLOPTTYPE_OBJECTPOINT + 25,
  CURLOPT_KEYPASSWD = CURLOPTTYPE_OBJECTPOINT + 26,
  CURLOPT_CRLF = CURLOPTTYPE_LONG + 27,
  CURLOPT_QUOTE = CURLOPTTYPE_OBJECTPOINT + 28,
  CURLOPT_HEADERDATA = CURLOPTTYPE_OBJECTPOINT + 29,
  CURLOPT_COOKIEFILE = CURLOPTTYPE_OBJECTPOINT + 31,
  CURLOPT_SSLVERSION = CURLOPTTYPE_LONG + 32,
  CURLOPT_TIMECONDITION = CURLOPTTYPE_LONG + 33,
  CURLOPT_TIMEVALUE = CURLOPTTYPE_LONG + 34,
  CURLOPT_CUSTOMREQUEST = CURLOPTTYPE_OBJECTPOINT + 36,
  CURLOPT_STDERR = CURLOPTTYPE_OBJECTPOINT + 37,
  CURLOPT_POSTQUOTE = CURLOPTTYPE_OBJECTPOINT + 39,
  CURLOPT_OBSOLETE40 = CURLOPTTYPE_OBJECTPOINT + 40,
  CURLOPT_VERBOSE = CURLOPTTYPE_LONG + 41,
  CURLOPT_HEADER = CURLOPTTYPE_LONG + 42,
  CURLOPT_NOPROGRESS = CURLOPTTYPE_LONG + 43,
  CURLOPT_NOBODY = CURLOPTTYPE_LONG + 44,
  CURLOPT_FAILONERROR = CURLOPTTYPE_LONG + 45,
  CURLOPT_UPLOAD = CURLOPTTYPE_LONG + 46,
  CURLOPT_POST = CURLOPTTYPE_LONG + 47,
  CURLOPT_DIRLISTONLY = CURLOPTTYPE_LONG + 48,
  CURLOPT_APPEND = CURLOPTTYPE_LONG + 50,
  CURLOPT_NETRC = CURLOPTTYPE_LONG + 51,
  CURLOPT_FOLLOWLOCATION = CURLOPTTYPE_LONG + 52,
  CURLOPT_TRANSFERTEXT = CURLOPTTYPE_LONG + 53,
  CURLOPT_PUT = CURLOPTTYPE_LONG + 54,
  CURLOPT_PROGRESSFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 56,
  CURLOPT_PROGRESSDATA = CURLOPTTYPE_OBJECTPOINT + 57,
  CURLOPT_AUTOREFERER = CURLOPTTYPE_LONG + 58,
  CURLOPT_PROXYPORT = CURLOPTTYPE_LONG + 59,
  CURLOPT_POSTFIELDSIZE = CURLOPTTYPE_LONG + 60,
  CURLOPT_HTTPPROXYTUNNEL = CURLOPTTYPE_LONG + 61,
  CURLOPT_INTERFACE = CURLOPTTYPE_OBJECTPOINT + 62,
  CURLOPT_KRBLEVEL = CURLOPTTYPE_OBJECTPOINT + 63,
  CURLOPT_SSL_VERIFYPEER = CURLOPTTYPE_LONG + 64,
  CURLOPT_CAINFO = CURLOPTTYPE_OBJECTPOINT + 65,
  CURLOPT_MAXREDIRS = CURLOPTTYPE_LONG + 68,
  CURLOPT_FILETIME = CURLOPTTYPE_LONG + 69,
  CURLOPT_TELNETOPTIONS = CURLOPTTYPE_OBJECTPOINT + 70,
  CURLOPT_MAXCONNECTS = CURLOPTTYPE_LONG + 71,
  CURLOPT_OBSOLETE72 = CURLOPTTYPE_LONG + 72,
  CURLOPT_FRESH_CONNECT = CURLOPTTYPE_LONG + 74,
  CURLOPT_FORBID_REUSE = CURLOPTTYPE_LONG + 75,
  CURLOPT_RANDOM_FILE = CURLOPTTYPE_OBJECTPOINT + 76,
  CURLOPT_EGDSOCKET = CURLOPTTYPE_OBJECTPOINT + 77,
  CURLOPT_CONNECTTIMEOUT = CURLOPTTYPE_LONG + 78,
  CURLOPT_HEADERFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 79,
  CURLOPT_HTTPGET = CURLOPTTYPE_LONG + 80,
  CURLOPT_SSL_VERIFYHOST = CURLOPTTYPE_LONG + 81,
  CURLOPT_COOKIEJAR = CURLOPTTYPE_OBJECTPOINT + 82,
  CURLOPT_SSL_CIPHER_LIST = CURLOPTTYPE_OBJECTPOINT + 83,
  CURLOPT_HTTP_VERSION = CURLOPTTYPE_LONG + 84,
  CURLOPT_FTP_USE_EPSV = CURLOPTTYPE_LONG + 85,
  CURLOPT_SSLCERTTYPE = CURLOPTTYPE_OBJECTPOINT + 86,
  CURLOPT_SSLKEY = CURLOPTTYPE_OBJECTPOINT + 87,
  CURLOPT_SSLKEYTYPE = CURLOPTTYPE_OBJECTPOINT + 88,
  CURLOPT_SSLENGINE = CURLOPTTYPE_OBJECTPOINT + 89,
  CURLOPT_SSLENGINE_DEFAULT = CURLOPTTYPE_LONG + 90,
  CURLOPT_DNS_USE_GLOBAL_CACHE = CURLOPTTYPE_LONG + 91,
  CURLOPT_DNS_CACHE_TIMEOUT = CURLOPTTYPE_LONG + 92,
  CURLOPT_PREQUOTE = CURLOPTTYPE_OBJECTPOINT + 93,
  CURLOPT_DEBUGFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 94,
  CURLOPT_DEBUGDATA = CURLOPTTYPE_OBJECTPOINT + 95,
  CURLOPT_COOKIESESSION = CURLOPTTYPE_LONG + 96,
  CURLOPT_CAPATH = CURLOPTTYPE_OBJECTPOINT + 97,
  CURLOPT_BUFFERSIZE = CURLOPTTYPE_LONG + 98,
  CURLOPT_NOSIGNAL = CURLOPTTYPE_LONG + 99,
  CURLOPT_SHARE = CURLOPTTYPE_OBJECTPOINT + 100,
  CURLOPT_PROXYTYPE = CURLOPTTYPE_LONG + 101,
  CURLOPT_ACCEPT_ENCODING = CURLOPTTYPE_OBJECTPOINT + 102,
  CURLOPT_PRIVATE = CURLOPTTYPE_OBJECTPOINT + 103,
  CURLOPT_HTTP200ALIASES = CURLOPTTYPE_OBJECTPOINT + 104,
  CURLOPT_UNRESTRICTED_AUTH = CURLOPTTYPE_LONG + 105,
  CURLOPT_FTP_USE_EPRT = CURLOPTTYPE_LONG + 106,
  CURLOPT_HTTPAUTH = CURLOPTTYPE_LONG + 107,
  CURLOPT_SSL_CTX_FUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 108,
  CURLOPT_SSL_CTX_DATA = CURLOPTTYPE_OBJECTPOINT + 109,
  CURLOPT_FTP_CREATE_MISSING_DIRS = CURLOPTTYPE_LONG + 110,
  CURLOPT_PROXYAUTH = CURLOPTTYPE_LONG + 111,
  CURLOPT_FTP_RESPONSE_TIMEOUT = CURLOPTTYPE_LONG + 112,
  CURLOPT_IPRESOLVE = CURLOPTTYPE_LONG + 113,
  CURLOPT_MAXFILESIZE = CURLOPTTYPE_LONG + 114,
  CURLOPT_INFILESIZE_LARGE = CURLOPTTYPE_OFF_T + 115,
  CURLOPT_RESUME_FROM_LARGE = CURLOPTTYPE_OFF_T + 116,
  CURLOPT_MAXFILESIZE_LARGE = CURLOPTTYPE_OFF_T + 117,
  CURLOPT_NETRC_FILE = CURLOPTTYPE_OBJECTPOINT + 118,
  CURLOPT_USE_SSL = CURLOPTTYPE_LONG + 119,
  CURLOPT_POSTFIELDSIZE_LARGE = CURLOPTTYPE_OFF_T + 120,
  CURLOPT_TCP_NODELAY = CURLOPTTYPE_LONG + 121,
  CURLOPT_FTPSSLAUTH = CURLOPTTYPE_LONG + 129,
  CURLOPT_IOCTLFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 130,
  CURLOPT_IOCTLDATA = CURLOPTTYPE_OBJECTPOINT + 131,
  CURLOPT_FTP_ACCOUNT = CURLOPTTYPE_OBJECTPOINT + 134,
  CURLOPT_COOKIELIST = CURLOPTTYPE_OBJECTPOINT + 135,
  CURLOPT_IGNORE_CONTENT_LENGTH = CURLOPTTYPE_LONG + 136,
  CURLOPT_FTP_SKIP_PASV_IP = CURLOPTTYPE_LONG + 137,
  CURLOPT_FTP_FILEMETHOD = CURLOPTTYPE_LONG + 138,
  CURLOPT_LOCALPORT = CURLOPTTYPE_LONG + 139,
  CURLOPT_LOCALPORTRANGE = CURLOPTTYPE_LONG + 140,
  CURLOPT_CONNECT_ONLY = CURLOPTTYPE_LONG + 141,
  CURLOPT_CONV_FROM_NETWORK_FUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 142,
  CURLOPT_CONV_TO_NETWORK_FUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 143,
  CURLOPT_CONV_FROM_UTF8_FUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 144,
  CURLOPT_MAX_SEND_SPEED_LARGE = CURLOPTTYPE_OFF_T + 145,
  CURLOPT_MAX_RECV_SPEED_LARGE = CURLOPTTYPE_OFF_T + 146,
  CURLOPT_FTP_ALTERNATIVE_TO_USER = CURLOPTTYPE_OBJECTPOINT + 147,
  CURLOPT_SOCKOPTFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 148,
  CURLOPT_SOCKOPTDATA = CURLOPTTYPE_OBJECTPOINT + 149,
  CURLOPT_SSL_SESSIONID_CACHE = CURLOPTTYPE_LONG + 150,
  CURLOPT_SSH_AUTH_TYPES = CURLOPTTYPE_LONG + 151,
  CURLOPT_SSH_PUBLIC_KEYFILE = CURLOPTTYPE_OBJECTPOINT + 152,
  CURLOPT_SSH_PRIVATE_KEYFILE = CURLOPTTYPE_OBJECTPOINT + 153,
  CURLOPT_FTP_SSL_CCC = CURLOPTTYPE_LONG + 154,
  CURLOPT_TIMEOUT_MS = CURLOPTTYPE_LONG + 155,
  CURLOPT_CONNECTTIMEOUT_MS = CURLOPTTYPE_LONG + 156,
  CURLOPT_HTTP_TRANSFER_DECODING = CURLOPTTYPE_LONG + 157,
  CURLOPT_HTTP_CONTENT_DECODING = CURLOPTTYPE_LONG + 158,
  CURLOPT_NEW_FILE_PERMS = CURLOPTTYPE_LONG + 159,
  CURLOPT_NEW_DIRECTORY_PERMS = CURLOPTTYPE_LONG + 160,
  CURLOPT_POSTREDIR = CURLOPTTYPE_LONG + 161,
  CURLOPT_SSH_HOST_PUBLIC_KEY_MD5 = CURLOPTTYPE_OBJECTPOINT + 162,
  CURLOPT_OPENSOCKETFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 163,
  CURLOPT_OPENSOCKETDATA = CURLOPTTYPE_OBJECTPOINT + 164,
  CURLOPT_COPYPOSTFIELDS = CURLOPTTYPE_OBJECTPOINT + 165,
  CURLOPT_PROXY_TRANSFER_MODE = CURLOPTTYPE_LONG + 166,
  CURLOPT_SEEKFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 167,
  CURLOPT_SEEKDATA = CURLOPTTYPE_OBJECTPOINT + 168,
  CURLOPT_CRLFILE = CURLOPTTYPE_OBJECTPOINT + 169,
  CURLOPT_ISSUERCERT = CURLOPTTYPE_OBJECTPOINT + 170,
  CURLOPT_ADDRESS_SCOPE = CURLOPTTYPE_LONG + 171,
  CURLOPT_CERTINFO = CURLOPTTYPE_LONG + 172,
  CURLOPT_USERNAME = CURLOPTTYPE_OBJECTPOINT + 173,
  CURLOPT_PASSWORD = CURLOPTTYPE_OBJECTPOINT + 174,
  CURLOPT_PROXYUSERNAME = CURLOPTTYPE_OBJECTPOINT + 175,
  CURLOPT_PROXYPASSWORD = CURLOPTTYPE_OBJECTPOINT + 176,
  CURLOPT_NOPROXY = CURLOPTTYPE_OBJECTPOINT + 177,
  CURLOPT_TFTP_BLKSIZE = CURLOPTTYPE_LONG + 178,
  CURLOPT_SOCKS5_GSSAPI_SERVICE = CURLOPTTYPE_OBJECTPOINT + 179,
  CURLOPT_SOCKS5_GSSAPI_NEC = CURLOPTTYPE_LONG + 180,
  CURLOPT_PROTOCOLS = CURLOPTTYPE_LONG + 181,
  CURLOPT_REDIR_PROTOCOLS = CURLOPTTYPE_LONG + 182,
  CURLOPT_SSH_KNOWNHOSTS = CURLOPTTYPE_OBJECTPOINT + 183,
  CURLOPT_SSH_KEYFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 184,
  CURLOPT_SSH_KEYDATA = CURLOPTTYPE_OBJECTPOINT + 185,
  CURLOPT_MAIL_FROM = CURLOPTTYPE_OBJECTPOINT + 186,
  CURLOPT_MAIL_RCPT = CURLOPTTYPE_OBJECTPOINT + 187,
  CURLOPT_FTP_USE_PRET = CURLOPTTYPE_LONG + 188,
  CURLOPT_RTSP_REQUEST = CURLOPTTYPE_LONG + 189,
  CURLOPT_RTSP_SESSION_ID = CURLOPTTYPE_OBJECTPOINT + 190,
  CURLOPT_RTSP_STREAM_URI = CURLOPTTYPE_OBJECTPOINT + 191,
  CURLOPT_RTSP_TRANSPORT = CURLOPTTYPE_OBJECTPOINT + 192,
  CURLOPT_RTSP_CLIENT_CSEQ = CURLOPTTYPE_LONG + 193,
  CURLOPT_RTSP_SERVER_CSEQ = CURLOPTTYPE_LONG + 194,
  CURLOPT_INTERLEAVEDATA = CURLOPTTYPE_OBJECTPOINT + 195,
  CURLOPT_INTERLEAVEFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 196,
  CURLOPT_WILDCARDMATCH = CURLOPTTYPE_LONG + 197,
  CURLOPT_CHUNK_BGN_FUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 198,
  CURLOPT_CHUNK_END_FUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 199,
  CURLOPT_FNMATCH_FUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 200,
  CURLOPT_CHUNK_DATA = CURLOPTTYPE_OBJECTPOINT + 201,
  CURLOPT_FNMATCH_DATA = CURLOPTTYPE_OBJECTPOINT + 202,
  CURLOPT_RESOLVE = CURLOPTTYPE_OBJECTPOINT + 203,
  CURLOPT_TLSAUTH_USERNAME = CURLOPTTYPE_OBJECTPOINT + 204,
  CURLOPT_TLSAUTH_PASSWORD = CURLOPTTYPE_OBJECTPOINT + 205,
  CURLOPT_TLSAUTH_TYPE = CURLOPTTYPE_OBJECTPOINT + 206,
  CURLOPT_TRANSFER_ENCODING = CURLOPTTYPE_LONG + 207,
  CURLOPT_CLOSESOCKETFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 208,
  CURLOPT_CLOSESOCKETDATA = CURLOPTTYPE_OBJECTPOINT + 209,
  CURLOPT_GSSAPI_DELEGATION = CURLOPTTYPE_LONG + 210,
  CURLOPT_DNS_SERVERS = CURLOPTTYPE_OBJECTPOINT + 211,
  CURLOPT_ACCEPTTIMEOUT_MS = CURLOPTTYPE_LONG + 212,
  CURLOPT_TCP_KEEPALIVE = CURLOPTTYPE_LONG + 213,
  CURLOPT_TCP_KEEPIDLE = CURLOPTTYPE_LONG + 214,
  CURLOPT_TCP_KEEPINTVL = CURLOPTTYPE_LONG + 215,
  CURLOPT_SSL_OPTIONS = CURLOPTTYPE_LONG + 216,
  CURLOPT_MAIL_AUTH = CURLOPTTYPE_OBJECTPOINT + 217,
  CURLOPT_SASL_IR = CURLOPTTYPE_LONG + 218,
  CURLOPT_XFERINFOFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 219,
  CURLOPT_XOAUTH2_BEARER = CURLOPTTYPE_OBJECTPOINT + 220,
  CURLOPT_DNS_INTERFACE = CURLOPTTYPE_OBJECTPOINT + 221,
  CURLOPT_DNS_LOCAL_IP4 = CURLOPTTYPE_OBJECTPOINT + 222,
  CURLOPT_DNS_LOCAL_IP6 = CURLOPTTYPE_OBJECTPOINT + 223,
  CURLOPT_LOGIN_OPTIONS = CURLOPTTYPE_OBJECTPOINT + 224,
  CURLOPT_SSL_ENABLE_NPN = CURLOPTTYPE_LONG + 225,
  CURLOPT_SSL_ENABLE_ALPN = CURLOPTTYPE_LONG + 226,
  CURLOPT_EXPECT_100_TIMEOUT_MS = CURLOPTTYPE_LONG + 227,
  CURLOPT_PROXYHEADER = CURLOPTTYPE_OBJECTPOINT + 228,
  CURLOPT_HEADEROPT = CURLOPTTYPE_LONG + 229,
  CURLOPT_LASTENTRY
} CURLoption;
static const int CURLOPT_XFERINFODATA = CURLOPT_PROGRESSDATA;
static const int CURLOPT_SERVER_RESPONSE_TIMEOUT = CURLOPT_FTP_RESPONSE_TIMEOUT;
static const int CURL_IPRESOLVE_WHATEVER = 0;
static const int CURL_IPRESOLVE_V4       = 1;
static const int CURL_IPRESOLVE_V6       = 2;
static const int CURLOPT_RTSPHEADER = CURLOPT_HTTPHEADER;
enum {
  CURL_HTTP_VERSION_NONE,
  CURL_HTTP_VERSION_1_0,
  CURL_HTTP_VERSION_1_1,
  CURL_HTTP_VERSION_2_0,
  CURL_HTTP_VERSION_LAST
};
enum {
    CURL_RTSPREQ_NONE,
    CURL_RTSPREQ_OPTIONS,
    CURL_RTSPREQ_DESCRIBE,
    CURL_RTSPREQ_ANNOUNCE,
    CURL_RTSPREQ_SETUP,
    CURL_RTSPREQ_PLAY,
    CURL_RTSPREQ_PAUSE,
    CURL_RTSPREQ_TEARDOWN,
    CURL_RTSPREQ_GET_PARAMETER,
    CURL_RTSPREQ_SET_PARAMETER,
    CURL_RTSPREQ_RECORD,
    CURL_RTSPREQ_RECEIVE,
    CURL_RTSPREQ_LAST
};
enum CURL_NETRC_OPTION {
  CURL_NETRC_IGNORED,
  CURL_NETRC_OPTIONAL,
  CURL_NETRC_REQUIRED,
  CURL_NETRC_LAST
};
enum {
  CURL_SSLVERSION_DEFAULT,
  CURL_SSLVERSION_TLSv1,
  CURL_SSLVERSION_SSLv2,
  CURL_SSLVERSION_SSLv3,
  CURL_SSLVERSION_TLSv1_0,
  CURL_SSLVERSION_TLSv1_1,
  CURL_SSLVERSION_TLSv1_2,
  CURL_SSLVERSION_LAST
};
enum CURL_TLSAUTH {
  CURL_TLSAUTH_NONE,
  CURL_TLSAUTH_SRP,
  CURL_TLSAUTH_LAST
};
static const int CURL_REDIR_GET_ALL  = 0;
static const int CURL_REDIR_POST_301 = 1;
static const int CURL_REDIR_POST_302 = 2;
static const int CURL_REDIR_POST_303 = 4;
static const int CURL_REDIR_POST_ALL = (CURL_REDIR_POST_301|CURL_REDIR_POST_302|CURL_REDIR_POST_303);
typedef enum {
  CURL_TIMECOND_NONE,
  CURL_TIMECOND_IFMODSINCE,
  CURL_TIMECOND_IFUNMODSINCE,
  CURL_TIMECOND_LASTMOD,
  CURL_TIMECOND_LAST
} curl_TimeCond;
typedef enum {
  CURLFORM_NOTHING,
  CURLFORM_COPYNAME,
  CURLFORM_PTRNAME,
  CURLFORM_NAMELENGTH,
  CURLFORM_COPYCONTENTS,
  CURLFORM_PTRCONTENTS,
  CURLFORM_CONTENTSLENGTH,
  CURLFORM_FILECONTENT,
  CURLFORM_ARRAY,
  CURLFORM_OBSOLETE,
  CURLFORM_FILE,
  CURLFORM_BUFFER,
  CURLFORM_BUFFERPTR,
  CURLFORM_BUFFERLENGTH,
  CURLFORM_CONTENTTYPE,
  CURLFORM_CONTENTHEADER,
  CURLFORM_FILENAME,
  CURLFORM_END,
  CURLFORM_OBSOLETE2,
  CURLFORM_STREAM,
  CURLFORM_LASTENTRY
} CURLformoption;
struct curl_forms {
  CURLformoption option;
  const char     *value;
};
typedef enum {
  CURL_FORMADD_OK,
  CURL_FORMADD_MEMORY,
  CURL_FORMADD_OPTION_TWICE,
  CURL_FORMADD_NULL,
  CURL_FORMADD_UNKNOWN_OPTION,
  CURL_FORMADD_INCOMPLETE,
  CURL_FORMADD_ILLEGAL_ARRAY,
  CURL_FORMADD_DISABLED,
  CURL_FORMADD_LAST
} CURLFORMcode;
CURLFORMcode curl_formadd(struct curl_httppost **httppost,
                                      struct curl_httppost **last_post,
                                      ...);
typedef size_t (*curl_formget_callback)(void *arg, const char *buf,
                                        size_t len);
int curl_formget(struct curl_httppost *form, void *arg,
                             curl_formget_callback append);
void curl_formfree(struct curl_httppost *form);
char *curl_getenv(const char *variable);
char *curl_version(void);
char *curl_easy_escape(CURL *handle,
                                   const char *string,
                                   int length);
char *curl_easy_unescape(CURL *handle,
                                     const char *string,
                                     int length,
                                     int *outlength);
void curl_free(void *p);
CURLcode curl_global_init(long flags);
CURLcode curl_global_init_mem(long flags,
                                          curl_malloc_callback m,
                                          curl_free_callback f,
                                          curl_realloc_callback r,
                                          curl_strdup_callback s,
                                          curl_calloc_callback c);
void curl_global_cleanup(void);
struct curl_slist {
  char *data;
  struct curl_slist *next;
};
struct curl_slist *curl_slist_append(struct curl_slist *,
                                                 const char *);
void curl_slist_free_all(struct curl_slist *);
curl_time_t curl_getdate(const char *p, const curl_time_t *unused);
struct curl_certinfo {
  int num_of_certs;
  struct curl_slist **certinfo;
};
typedef enum {
  CURLSSLBACKEND_NONE = 0,
  CURLSSLBACKEND_OPENSSL = 1,
  CURLSSLBACKEND_GNUTLS = 2,
  CURLSSLBACKEND_NSS = 3,
  CURLSSLBACKEND_QSOSSL = 4,
  CURLSSLBACKEND_GSKIT = 5,
  CURLSSLBACKEND_POLARSSL = 6,
  CURLSSLBACKEND_CYASSL = 7,
  CURLSSLBACKEND_SCHANNEL = 8,
  CURLSSLBACKEND_DARWINSSL = 9,
  CURLSSLBACKEND_AXTLS = 10
} curl_sslbackend;
struct curl_tlssessioninfo {
  curl_sslbackend backend;
  void *internals;
};
static const int CURLINFO_STRING   = 0x100000;
static const int CURLINFO_LONG     = 0x200000;
static const int CURLINFO_DOUBLE   = 0x300000;
static const int CURLINFO_SLIST    = 0x400000;
static const int CURLINFO_MASK     = 0x0fffff;
static const int CURLINFO_TYPEMASK = 0xf00000;
typedef enum {
  CURLINFO_NONE,
  CURLINFO_EFFECTIVE_URL    = CURLINFO_STRING + 1,
  CURLINFO_RESPONSE_CODE    = CURLINFO_LONG   + 2,
  CURLINFO_TOTAL_TIME       = CURLINFO_DOUBLE + 3,
  CURLINFO_NAMELOOKUP_TIME  = CURLINFO_DOUBLE + 4,
  CURLINFO_CONNECT_TIME     = CURLINFO_DOUBLE + 5,
  CURLINFO_PRETRANSFER_TIME = CURLINFO_DOUBLE + 6,
  CURLINFO_SIZE_UPLOAD      = CURLINFO_DOUBLE + 7,
  CURLINFO_SIZE_DOWNLOAD    = CURLINFO_DOUBLE + 8,
  CURLINFO_SPEED_DOWNLOAD   = CURLINFO_DOUBLE + 9,
  CURLINFO_SPEED_UPLOAD     = CURLINFO_DOUBLE + 10,
  CURLINFO_HEADER_SIZE      = CURLINFO_LONG   + 11,
  CURLINFO_REQUEST_SIZE     = CURLINFO_LONG   + 12,
  CURLINFO_SSL_VERIFYRESULT = CURLINFO_LONG   + 13,
  CURLINFO_FILETIME         = CURLINFO_LONG   + 14,
  CURLINFO_CONTENT_LENGTH_DOWNLOAD   = CURLINFO_DOUBLE + 15,
  CURLINFO_CONTENT_LENGTH_UPLOAD     = CURLINFO_DOUBLE + 16,
  CURLINFO_STARTTRANSFER_TIME = CURLINFO_DOUBLE + 17,
  CURLINFO_CONTENT_TYPE     = CURLINFO_STRING + 18,
  CURLINFO_REDIRECT_TIME    = CURLINFO_DOUBLE + 19,
  CURLINFO_REDIRECT_COUNT   = CURLINFO_LONG   + 20,
  CURLINFO_PRIVATE          = CURLINFO_STRING + 21,
  CURLINFO_HTTP_CONNECTCODE = CURLINFO_LONG   + 22,
  CURLINFO_HTTPAUTH_AVAIL   = CURLINFO_LONG   + 23,
  CURLINFO_PROXYAUTH_AVAIL  = CURLINFO_LONG   + 24,
  CURLINFO_OS_ERRNO         = CURLINFO_LONG   + 25,
  CURLINFO_NUM_CONNECTS     = CURLINFO_LONG   + 26,
  CURLINFO_SSL_ENGINES      = CURLINFO_SLIST  + 27,
  CURLINFO_COOKIELIST       = CURLINFO_SLIST  + 28,
  CURLINFO_LASTSOCKET       = CURLINFO_LONG   + 29,
  CURLINFO_FTP_ENTRY_PATH   = CURLINFO_STRING + 30,
  CURLINFO_REDIRECT_URL     = CURLINFO_STRING + 31,
  CURLINFO_PRIMARY_IP       = CURLINFO_STRING + 32,
  CURLINFO_APPCONNECT_TIME  = CURLINFO_DOUBLE + 33,
  CURLINFO_CERTINFO         = CURLINFO_SLIST  + 34,
  CURLINFO_CONDITION_UNMET  = CURLINFO_LONG   + 35,
  CURLINFO_RTSP_SESSION_ID  = CURLINFO_STRING + 36,
  CURLINFO_RTSP_CLIENT_CSEQ = CURLINFO_LONG   + 37,
  CURLINFO_RTSP_SERVER_CSEQ = CURLINFO_LONG   + 38,
  CURLINFO_RTSP_CSEQ_RECV   = CURLINFO_LONG   + 39,
  CURLINFO_PRIMARY_PORT     = CURLINFO_LONG   + 40,
  CURLINFO_LOCAL_IP         = CURLINFO_STRING + 41,
  CURLINFO_LOCAL_PORT       = CURLINFO_LONG   + 42,
  CURLINFO_TLS_SESSION      = CURLINFO_SLIST  + 43,
  CURLINFO_LASTONE          = 43
} CURLINFO;
static const int CURLINFO_HTTP_CODE = CURLINFO_RESPONSE_CODE;
typedef enum {
  CURLCLOSEPOLICY_NONE,
  CURLCLOSEPOLICY_OLDEST,
  CURLCLOSEPOLICY_LEAST_RECENTLY_USED,
  CURLCLOSEPOLICY_LEAST_TRAFFIC,
  CURLCLOSEPOLICY_SLOWEST,
  CURLCLOSEPOLICY_CALLBACK,
  CURLCLOSEPOLICY_LAST
} curl_closepolicy;
static const int CURL_GLOBAL_SSL = (1<<0);
static const int CURL_GLOBAL_WIN32 = (1<<1);
static const int CURL_GLOBAL_ALL = (CURL_GLOBAL_SSL|CURL_GLOBAL_WIN32);
static const int CURL_GLOBAL_NOTHING = 0;
static const int CURL_GLOBAL_DEFAULT = CURL_GLOBAL_ALL;
static const int CURL_GLOBAL_ACK_EINTR = (1<<2);
typedef enum {
  CURL_LOCK_DATA_NONE = 0,
  CURL_LOCK_DATA_SHARE,
  CURL_LOCK_DATA_COOKIE,
  CURL_LOCK_DATA_DNS,
  CURL_LOCK_DATA_SSL_SESSION,
  CURL_LOCK_DATA_CONNECT,
  CURL_LOCK_DATA_LAST
} curl_lock_data;
typedef enum {
  CURL_LOCK_ACCESS_NONE = 0,
  CURL_LOCK_ACCESS_SHARED = 1,
  CURL_LOCK_ACCESS_SINGLE = 2,
  CURL_LOCK_ACCESS_LAST
} curl_lock_access;
typedef void (*curl_lock_function)(CURL *handle,
                                   curl_lock_data data,
                                   curl_lock_access locktype,
                                   void *userptr);
typedef void (*curl_unlock_function)(CURL *handle,
                                     curl_lock_data data,
                                     void *userptr);
typedef void CURLSH;
typedef enum {
  CURLSHE_OK,
  CURLSHE_BAD_OPTION,
  CURLSHE_IN_USE,
  CURLSHE_INVALID,
  CURLSHE_NOMEM,
  CURLSHE_NOT_BUILT_IN,
  CURLSHE_LAST
} CURLSHcode;
typedef enum {
  CURLSHOPT_NONE,
  CURLSHOPT_SHARE,
  CURLSHOPT_UNSHARE,
  CURLSHOPT_LOCKFUNC,
  CURLSHOPT_UNLOCKFUNC,
  CURLSHOPT_USERDATA,
  CURLSHOPT_LAST
} CURLSHoption;
CURLSH *curl_share_init(void);
CURLSHcode curl_share_setopt(CURLSH *, CURLSHoption option, ...);
CURLSHcode curl_share_cleanup(CURLSH *);
typedef enum {
  CURLVERSION_FIRST,
  CURLVERSION_SECOND,
  CURLVERSION_THIRD,
  CURLVERSION_FOURTH,
  CURLVERSION_LAST
} CURLversion;
static const int CURLVERSION_NOW = CURLVERSION_FOURTH;
typedef struct {
  CURLversion age;
  const char *version;
  unsigned int version_num;
  const char *host;
  int features;
  const char *ssl_version;
  long ssl_version_num;
  const char *libz_version;
  const char * const *protocols;
  const char *ares;
  int ares_num;
  const char *libidn;
  int iconv_ver_num;
  const char *libssh_version;
} curl_version_info_data;
static const int CURL_VERSION_IPV6      = (1<<0);
static const int CURL_VERSION_KERBEROS4 = (1<<1);
static const int CURL_VERSION_SSL       = (1<<2);
static const int CURL_VERSION_LIBZ      = (1<<3);
static const int CURL_VERSION_NTLM      = (1<<4);
static const int CURL_VERSION_GSSNEGOTIATE = (1<<5);
static const int CURL_VERSION_DEBUG     = (1<<6);
static const int CURL_VERSION_ASYNCHDNS = (1<<7);
static const int CURL_VERSION_SPNEGO    = (1<<8);
static const int CURL_VERSION_LARGEFILE = (1<<9);
static const int CURL_VERSION_IDN       = (1<<10);
static const int CURL_VERSION_SSPI      = (1<<11);
static const int CURL_VERSION_CONV      = (1<<12);
static const int CURL_VERSION_CURLDEBUG = (1<<13);
static const int CURL_VERSION_TLSAUTH_SRP = (1<<14);
static const int CURL_VERSION_NTLM_WB   = (1<<15);
static const int CURL_VERSION_HTTP2     = (1<<16);
static const int CURL_VERSION_GSSAPI    = (1<<17);
curl_version_info_data *curl_version_info(CURLversion);
const char *curl_easy_strerror(CURLcode);
const char *curl_share_strerror(CURLSHcode);
CURLcode curl_easy_pause(CURL *handle, int bitmask);
static const int CURLPAUSE_RECV      = (1<<0);
static const int CURLPAUSE_RECV_CONT = (0);
static const int CURLPAUSE_SEND      = (1<<2);
static const int CURLPAUSE_SEND_CONT = (0);
static const int CURLPAUSE_ALL       = (CURLPAUSE_RECV|CURLPAUSE_SEND);
static const int CURLPAUSE_CONT      = (CURLPAUSE_RECV_CONT|CURLPAUSE_SEND_CONT);
//#define curl_easy_setopt(handle,opt,param) curl_easy_setopt(handle,opt,param)
//#define curl_easy_getinfo(handle,info,arg) curl_easy_getinfo(handle,info,arg)
//#define curl_share_setopt(share,opt,param) curl_share_setopt(share,opt,param)
//#define curl_multi_setopt(handle,opt,param) curl_multi_setopt(handle,opt,param)
]]
M.CURLoption = ffi.typeof("CURLoption")
M.CURLINFO = ffi.typeof("CURLINFO")
-- ]> curl.h

-- <[ easy.h
ffi.cdef[[
CURL *curl_easy_init(void);
CURLcode curl_easy_setopt(CURL *curl, CURLoption option, ...);
CURLcode curl_easy_perform(CURL *curl);
void curl_easy_cleanup(CURL *curl);
CURLcode curl_easy_getinfo(CURL *curl, CURLINFO info, ...);
CURL* curl_easy_duphandle(CURL *curl);
void curl_easy_reset(CURL *curl);
CURLcode curl_easy_recv(CURL *curl, void *buffer, size_t buflen,
                                    size_t *n);
CURLcode curl_easy_send(CURL *curl, const void *buffer,
                                    size_t buflen, size_t *n);
]]
M.curl_easy_setopt = function(a,b,c)
  return lib.curl_easy_setopt(a, b, c)
end
M.curl_easy_getopt = function(a,b,c)
  return lib.curl_easy_getopt(a, b, c)
end

local curl_easy_getinfo_transtbl = { }
curl_easy_getinfo_transtbl[tonumber(lib.CURLINFO_STRING)] = function(s) 
    if s == nil then return ffi.new("char*[1]") end
    local r = ffi.string(s[0])
    -- lib.curl_free(s[0]) DON'T FREE HERE
    return r
  end
curl_easy_getinfo_transtbl[tonumber(lib.CURLINFO_LONG)] = function(n) 
    if n == nil then return ffi.new("long[1]") end
    return n[0]
  end
curl_easy_getinfo_transtbl[tonumber(lib.CURLINFO_DOUBLE)] = function(n) 
    if n == nil then return ffi.new("double[1]") end
    return n[0]
  end
curl_easy_getinfo_transtbl[tonumber(lib.CURLINFO_SLIST)] = function(sl)
    if sl == nil then return ffi.new("void*[1]") end
    return sl[0]
  end

function curl_easy_getinfo_prepare(info)
  local fn = curl_easy_getinfo_transtbl[
      bit.band(tonumber(ffi.cast(M.CURLINFO, info)), 
         lib.CURLINFO_TYPEMASK)
    ]
  if fn == nil then return nil, function() return nil end end
  return fn(nil), fn
end
function M.curl_slist_to_table(sl, free)
  assert(sl ~= nil and ffi.istype("struct curl_slist", sl))
  local r = {}
  local p=sl
  repeat
    r[#r+1] = p.data ~= nil and ffi.string(p.data) or nil
    p = p.next
  until p == nil
  if free and sl ~= nil then lib.curl_slist_free_all(sl) end
  return r
end

function M.curl_slist_from_table(table)
  local sl
  for _,v in ipairs(table) do
    sl = lib.curl_slist_append(sl, tostring(v))
  end
  return sl
end

M.Easy=ffi.metatype("CURL", {
  __index = {
    init = function(self)
      assert(self == nil)
      return ffi.gc(lib.curl_easy_init(), lib.curl_easy_cleanup)
    end,
    duphandle = function(self)
      assert(self ~= nil)
      return ffi.gc(lib.curl_easy_duphandle(self), lib.curl_easy_cleanup)
    end,
    reset = function(self)
      assert(self ~= nil)
      return lib.curl_easy_reset(self)
    end,
    setopt = function(self, option, value)
      assert(self ~= nil)
      option = ffi.cast(M.CURLoption, option)
      if option > lib.CURLOPTTYPE_OFF_T then
        if not ffi.istype(M.Off_t, value) then value = M.Off_t(value) end
      elseif option > lib.CURLOPTTYPE_FUNCTIONPOINT then
        assert(type(value) == 'cdata')
      elseif option > lib.CURLOPTTYPE_OBJECTPOINT then
        assert(type(value) ~= 'function' and type(value) ~= 'table')
      else
        if not ffi.istype(M.Long, value) then value = M.Long(value) end
      end
      return lib.curl_easy_setopt(self, option, value)
    end,
    getinfo = function(self, info)
      assert(self ~= nil)
      local buffer, marshal = curl_easy_getinfo_prepare(info)
      local r = lib.curl_easy_getinfo(self, info, buffer)
      if r ~= lib.CURLE_OK then return nil, r end
      return marshal(buffer), r
    end,
    perform = function(self)
      assert(self ~= nil)
      return lib.curl_easy_perform(self)
    end,
    pause = function(self, bitmask)
      return lib.curl_easy_pause(self, bitmask)
    end,
    escape = function(self, string, length, keep_char)
      assert(self ~= nil)
      length = length or string.len(string)
      local s = lib.curl_easy_escape(self, string, length)
      if s == nil or keep_char then return s end
      local s2 = ffi.string(s)
      lib.curl_free(s)
      return s2
    end,
    unescape = function(self, string, length, keep_char)
      assert(self ~= nil)
      local outlength = ffi.new("int[1]", 0)
      length = length or string.len(string)
      local s = lib.curl_easy_unescape(self, string, length, outlength)
      if s == nil or keep_char then return s, outlength[0] end
      local s2 = ffi.string(s, outlength[0])
      lib.curl_free(s)
      return s2, outlength[0]
    end,
    recv = function(self, recvlen)
      recvlen = recvlen or 2048
      local buffer = ffi.new("char[?]", recvlen)
      local got = ffi.new("size_t[1]", 0)
      local res = lib.curl_easy_recv(self, buffer, recvlen, got)
      return ffi.string(buffer, got[0]), res, got[0]
    end,
    send = function(self, string, len)
      if string == nil then 
        len = 0
      elseif len < 1 then
        string = tostring(string)
        len = string.len(string)
      end
      local got = ffi.new("size_t[1]", 0)
      local res = lib.curl_easy_send(self, string, len, got)
      return res, got[0]
    end,
    strerror = function(err, selfed)
      return ffi.string(lib.curl_easy_strerror(selfed or err))
    end
  };
})


-- ]> easy.h

-- <[ multi.h
ffi.cdef[[
typedef struct {char __private;} CURLM;
typedef enum {
  CURLM_CALL_MULTI_PERFORM = -1,
  CURLM_OK,
  CURLM_BAD_HANDLE,
  CURLM_BAD_EASY_HANDLE,
  CURLM_OUT_OF_MEMORY,
  CURLM_INTERNAL_ERROR,
  CURLM_BAD_SOCKET,
  CURLM_UNKNOWN_OPTION,
  CURLM_ADDED_ALREADY,
  CURLM_LAST
} CURLMcode;
static const int CURLM_CALL_MULTI_SOCKET = CURLM_CALL_MULTI_PERFORM;
typedef enum {
  CURLMSG_NONE,
  CURLMSG_DONE,
  CURLMSG_LAST
} CURLMSG;
struct CURLMsg {
  CURLMSG msg;
  CURL *easy_handle;
  union {
    void *whatever;
    CURLcode result;
  } data;
};
typedef struct CURLMsg CURLMsg;
static const int CURL_WAIT_POLLIN    = 0x0001;
static const int CURL_WAIT_POLLPRI   = 0x0002;
static const int CURL_WAIT_POLLOUT   = 0x0004;
struct curl_waitfd {
  curl_socket_t fd;
  short events;
  short revents;
};
CURLM *curl_multi_init(void);
CURLMcode curl_multi_add_handle(CURLM *multi_handle,
                                            CURL *curl_handle);
CURLMcode curl_multi_remove_handle(CURLM *multi_handle,
                                               CURL *curl_handle);
CURLMcode curl_multi_fdset(CURLM *multi_handle,
                                       curl_fd_set *read_fd_set,
                                       curl_fd_set *write_fd_set,
                                       curl_fd_set *exc_fd_set,
                                       int *max_fd);
CURLMcode curl_multi_wait(CURLM *multi_handle,
                                      struct curl_waitfd extra_fds[],
                                      unsigned int extra_nfds,
                                      int timeout_ms,
                                      int *ret);
CURLMcode curl_multi_perform(CURLM *multi_handle,
                                         int *running_handles);
CURLMcode curl_multi_cleanup(CURLM *multi_handle);
CURLMsg *curl_multi_info_read(CURLM *multi_handle,
                                          int *msgs_in_queue);
const char *curl_multi_strerror(CURLMcode);
static const int CURL_POLL_NONE   = 0;
static const int CURL_POLL_IN     = 1;
static const int CURL_POLL_OUT    = 2;
static const int CURL_POLL_INOUT  = 3;
static const int CURL_POLL_REMOVE = 4;
static const int CURL_SOCKET_TIMEOUT = CURL_SOCKET_BAD;
static const int CURL_CSELECT_IN   = 0x01;
static const int CURL_CSELECT_OUT  = 0x02;
static const int CURL_CSELECT_ERR  = 0x04;
typedef int (*curl_socket_callback)(CURL *easy,
                                    curl_socket_t s,
                                    int what,
                                    void *userp,
                                    void *socketp);
typedef int (*curl_multi_timer_callback)(CURLM *multi,
                                         long timeout_ms,
                                         void *userp);
CURLMcode curl_multi_socket_action(CURLM *multi_handle,
                                               curl_socket_t s,
                                               int ev_bitmask,
                                               int *running_handles);
CURLMcode curl_multi_socket_all(CURLM *multi_handle,
                                            int *running_handles);
/*
CURLMcode curl_multi_socket(CURLM *multi_handle, curl_socket_t s,
                                        int *running_handles);
#ifndef CURL_ALLOW_OLD_MULTI_SOCKET
#define curl_multi_socket(x,y,z) curl_multi_socket_action(x,y,0,z)
#endif
*/
CURLMcode curl_multi_timeout(CURLM *multi_handle,
                                         long *milliseconds);
typedef enum {
  CURLMOPT_SOCKETFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 1,
  CURLMOPT_SOCKETDATA = CURLOPTTYPE_OBJECTPOINT + 2,
  CURLMOPT_PIPELINING = CURLOPTTYPE_LONG + 3,
  CURLMOPT_TIMERFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 4,
  CURLMOPT_TIMERDATA = CURLOPTTYPE_OBJECTPOINT + 5,
  CURLMOPT_MAXCONNECTS = CURLOPTTYPE_LONG + 6,
  CURLMOPT_MAX_HOST_CONNECTIONS = CURLOPTTYPE_LONG + 7,
  CURLMOPT_MAX_PIPELINE_LENGTH = CURLOPTTYPE_LONG + 8,
  CURLMOPT_CONTENT_LENGTH_PENALTY_SIZE = CURLOPTTYPE_OFF_T + 9,
  CURLMOPT_CHUNK_LENGTH_PENALTY_SIZE = CURLOPTTYPE_OFF_T + 10,
  CURLMOPT_PIPELINING_SITE_BL = CURLOPTTYPE_OBJECTPOINT + 11,
  CURLMOPT_PIPELINING_SERVER_BL = CURLOPTTYPE_OBJECTPOINT + 12,
  CURLMOPT_MAX_TOTAL_CONNECTIONS = CURLOPTTYPE_LONG + 13,
  CURLMOPT_LASTENTRY
} CURLMoption;
CURLMcode curl_multi_setopt(CURLM *multi_handle,
                                        CURLMoption option, ...);
CURLMcode curl_multi_assign(CURLM *multi_handle,
                                        curl_socket_t sockfd, void *sockp);
]]
-- ]> multi.h

local __curl_cleanup_gc_hook
function M.init(flags, ...)
  local res
  flags = flags or 0
  if select('#', ...) == 4 then
    res = lib.curl_global_init_mem(flags, ...)
  else
    assert(select('#', ...) == 0)
    res = lib.curl_global_init(flags)
  end
  __curl_cleanup_gc_hook = ffi.gc(ffi.new("void*"), function(_) 
    lib.curl_global_cleanup()
  end)
  return res
end

function M.version()
  return ffi.string(lib.curl_version())
end
function M.version_info()
  local c = lib.curl_version_info(lib.CURLVERSION_NOW)
  local t = {
    age = tonumber(c.age),
    version = c.version ~= nil and ffi.string(c.version),
    version_num = tonumber(c.version_num),
    host = c.host ~= nil and ffi.string(c.host),
    features = {},
    features_flags = c.features,
    ssl_version = c.ssl_version ~= nil and ffi.string(c.ssl_version),
    ssl_version_num = tonumber(c.ssl_version_num),
    libz_version = c.libz_version ~= nil and ffi.string(c.libz_version),
    protocols = {}
  }
  if t.age > 0 then  
    t.ares = c.ares ~= nil and ffi.string(c.ares)
    t.ares_num = tonumber(c.ares_num)
  if t.age > 1 then
    t.libidn = c.libidn ~= nil and ffi.string(c.libidn)
  if t.age > 2 then
    iconv_ver_num = tonumber(c.iconv_ver_num)
    libssh_version = c.libssh_version ~= nil and ffi.string(c.libssh_version)
  end
  end
  end
  local f = tonumber(c.features)
  for _,v in ipairs{"IPV6","KERBEROS4","SSL","LIBZ","NTLM","GSSNEGOTIATE",
        "DEBUG","ASYNCHDNS","SPNEGO","LARGEFILE","IDN","SSPI","CONV",
        "CURLDEBUG","TLSAUTH_SRP","NTLM_WB","HTTP2","GSSAPI"} do
    if 0 ~= bit.band(f, lib["CURL_VERSION_"..v]) then
      t.features[#t.features+1] = v
    end
  end
  t.features = table.concat(t.features, ", ")

  if c.protocols == nil then return t end
  local i = 0
  while c.protocols[i] ~= nil do
    t.protocols[i] = ffi.string(c.protocols[i])
    i=i+1
  end
  return t
end
M.Null = ffi.new("void*", nil)
M.Ptr = ffi.typeof("void*")
M.Callback = { 
  Write = ffi.typeof("curl_write_callback"),
  Header = ffi.typeof("curl_write_callback"),
  Progress = ffi.typeof("curl_progress_callback"),
  Xferinfo = ffi.typeof("curl_xferinfo_callback"),
  Formget = ffi.typeof("curl_formget_callback"),
  Chunk_bgn = ffi.typeof("curl_chunk_bgn_callback"),
  Chunk_end = ffi.typeof("curl_chunk_end_callback"),
  Fnmatch = ffi.typeof("curl_fnmatch_callback"),
  Seek = ffi.typeof("curl_seek_callback"),
  Read = ffi.typeof("curl_read_callback"),
  Sockopt = ffi.typeof("curl_sockopt_callback"),
  Opensocket = ffi.typeof("curl_opensocket_callback"),
  Closesocket = ffi.typeof("curl_closesocket_callback"),
  Debug = ffi.typeof("curl_debug_callback"),
  Conv = ffi.typeof("curl_conv_callback"),
  Ssl_ctx = ffi.typeof("curl_ssl_ctx_callback"),
  Ioctl = ffi.typeof("curl_ioctl_callback"),
  Socket = ffi.typeof("curl_socket_callback"),
  Multi_timer = ffi.typeof("curl_multi_timer_callback"),
}
M.Off_t = ffi.typeof("curl_off_t")
M.Long = ffi.typeof("long")
M.SList = {
  from_table = M.curl_slist_from_table,
  to_table = M.curl_slist_to_table,
  free = M.curl_slist_free_all,
  append = M.curl_slist_append
}

function M.getdate(datestring)
  return tonumber(lib.curl_getdate(datestring, nil))
end


function M.WriteBuffer()
  local buffer = {}
  local cb = ffi.cast(M.Callback.Write, 
    function(data, msize, nmemb, id)
      local size = msize*nmemb
      if size == 0 then return 0 end
      buffer[#buffer+1] = ffi.string(data, size)
      return size
    end)
  local __gc = ffi.gc(ffi.new("void*"),
    function() cb:free(); cb=nil end)
  return setmetatable({}, {cb=cb,buffer=buffer,ffigc=__gc, __index = {
      getwritecb = function(self) return cb end,
      write = function(self,text)
          local len=#text
          if len < 1 then return 0 end
          buffer[#buffer+1] = text
          return len
        end,
      read = function(self) return table.concat(buffer) end,
      clear = function(self) buffer = {} end
    }
  })
end


-- skip example if not called directly
if pcall(getfenv, 4) then return M end

M.init(M.CURL_GLOBAL_ALL)
c = M.Easy.init()

buf = M.WriteBuffer()
hb = M.WriteBuffer()
c:setopt("CURLOPT_HEADERFUNCTION", hb:getwritecb())
c:setopt("CURLOPT_HEADERDATA", M.Null)
c:setopt("CURLOPT_WRITEFUNCTION", buf:getwritecb())
c:setopt("CURLOPT_WRITEDATA", M.Null)
--c:setopt("CURLOPT_URL", "http://example.com")
c:setopt("CURLOPT_URL", "https://aur.archlinux.org/rpc.php?type=info&v=3&arg=libindicator-gtk2")
status = c:perform()
if status ~= M.CURLE_OK then print("!!Error:", c:strerror(status)) end
print("## HEADER ##")
print(hb:read())
print("## BODY ##")
print(buf:read())
buf:clear()
hb:clear()
buf=nil

print(c:getinfo("CURLINFO_EFFECTIVE_URL"))
-- vim: set ts=2 sw=2 tw=0 et : --
