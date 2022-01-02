# p2p-chat : A chat application running on ad-hoc network infrastructure 

Demonstrates how to use the flutter_nearby_connections plugin.

## Basic Idea

This is proof of concept, the idea is to check if it is possible to build a full-pfledged chat application which could run without the help 
of a central network infratructure such as cellular network or wifi-acess point connected to internet. This could be especially built for maintaining communication during crisis siutation when central network can be unavailable.

So far it relies on ad-hoc communication mediums for delivering messages. We primarily use the bluetooth/wifi-direct for device-device communication (Check Google nearby connections for more details on the communication technology used) 


Inspiration:
- https://ieeexplore.ieee.org/abstract/document/8888115
- https://ieeexplore.ieee.org/abstract/document/936316
- https://arxiv.org/ftp/arxiv/papers/1507/1507.00650.pdf


