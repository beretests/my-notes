Round robin network load balancing rotates connection requests among web servers in the order that requests are received. For a simplified example, assume that an enterprise has a cluster of three servers: Server A, Server B, and Server C.

• The first request is sent to Server A.
• The second request is sent to Server B.
• The third request is sent to Server C.

The load balancer continues passing requests to servers based on this order. This ensures that the server load is distributed evenly to handle high traffic.