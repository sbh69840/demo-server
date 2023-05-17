#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <unordered_map>
#include <fstream>

#include <cstdlib>
#include <cstring>

#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sw/redis++/redis++.h>

constexpr int PORT = 8080;
constexpr int BUFFER_SIZE = 1024;

void respond(int client_sockfd, const std::string& response) {
    std::stringstream response_stream;
    response_stream << "HTTP/1.1 200 OK\r\n"
                    << "Content-Type: text/plain\r\n"
                    << "Connection: keep-alive\r\n"
                    << "Content-Length: " << response.length() << "\r\n"
                    << "\r\n"
                    << response;
    std::string response_str = response_stream.str();

    // send response to client
    write(client_sockfd, response_str.c_str(), response_str.length());
}

int main() {
    int server_sockfd, client_sockfd;
    struct sockaddr_in server_address, client_address;
    socklen_t client_address_len;

    // create socket
    server_sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_sockfd < 0) {
        std::cerr << "Error: Failed to create socket.\n";
        return 1;
    }

    // set server address
    std::memset(&server_address, 0, sizeof(server_address));
    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = htonl(INADDR_ANY);
    server_address.sin_port = htons(PORT);

    // bind socket to server address
    if (bind(server_sockfd, reinterpret_cast<struct sockaddr*>(&server_address), sizeof(server_address)) < 0) {
        std::cerr << "Error: Failed to bind socket.\n";
        close(server_sockfd);
        return 1;
    }

    // listen for incoming connections
    if (listen(server_sockfd, 5) < 0) {
        std::cerr << "Error: Failed to listen for connections.\n";
        close(server_sockfd);
        return 1;
    }

    // Connect to redis server
    sw::redis::ConnectionOptions connection_options;
    connection_options.host = "127.0.0.1";
    connection_options.port = 6379;
    sw::redis::Redis redis_client(connection_options);


    std::cout << "Server is listening on port " << PORT << ".\n";

    while (true) {
        // accept incoming connection
        client_address_len = sizeof(client_address);
        client_sockfd = accept(server_sockfd, reinterpret_cast<struct sockaddr*>(&client_address), &client_address_len);
        if (client_sockfd < 0) {
            std::cerr << "Error: Failed to accept connection.\n";
            close(server_sockfd);
            return 1;
        }

        // receive request from client
        char buffer[BUFFER_SIZE];
        int n = read(client_sockfd, buffer, BUFFER_SIZE);
        if (n < 0) {
            std::cerr << "Error: Failed to read request.\n";
            close(client_sockfd);
            continue;
        }
        std::string request(buffer, n);

        // parse request
        std::stringstream request_stream(request);
        std::string method, path, protocol;
        request_stream >> method >> path >> protocol;
        // handle GET request
        if (method == "GET" && path == "/get_foo") {
          try {
              redis_client.set("mykey", "myvalue");
          } catch (const sw::redis::Error &e) {
              std::cerr << "Error: Failed to set key-value pair: " << e.what() << std::endl;
              return 1;
          }
          respond(client_sockfd, "Key set");
        } else {
            std::string response = "Method or path not supported.";
            respond(client_sockfd, response);
        }

        // close
    }
}
