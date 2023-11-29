#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <ifaddrs.h>
#include <linux/if_packet.h>
#include <netinet/ether.h>

int main() {
    struct ifaddrs *ifaddr, *ifa;
    int family, s;
    char host[NI_MAXHOST];

    if (getifaddrs(&ifaddr) == -1) {
        perror("getifaddrs");
        exit(EXIT_FAILURE);
    }

    // Walk through the linked list of interfaces
    for (ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next) {
        if (ifa->ifa_addr == NULL)
            continue;

        family = ifa->ifa_addr->sa_family;

        // For an AF_PACKET interface, display the MAC address
        if (family == AF_PACKET) {
            struct sockaddr_ll *s = (struct sockaddr_ll*)ifa->ifa_addr;
            printf("Interface : %s\n", ifa->ifa_name);
            printf("   MAC Address : ");
            for (int i = 0; i < s->sll_halen; i++) {
                printf("%02x%c", (s->sll_addr[i]), (i + 1 != s->sll_halen) ? ':' : '\n');
            }
        }

        // For an AF_INET* interface, display the IP address
        if (family == AF_INET) {
            s = getnameinfo(ifa->ifa_addr, sizeof(struct sockaddr_in),
                            host, NI_MAXHOST,
                            NULL, 0, NI_NUMERICHOST);

            if (s != 0) {
                printf("getnameinfo() failed: %s\n", gai_strerror(s));
                exit(EXIT_FAILURE);
            }

            printf("   IP Address : %s\n", host);
        }
    }

    freeifaddrs(ifaddr);
    exit(EXIT_SUCCESS);
}

