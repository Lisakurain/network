# Linux网路设备

## 主要流程

### ingress

入的流量进入一个网络设备，如果L2联通则先在L2流通，然后调用network stack交由route table。route table判断接下来数据包交由哪个网络设备处理，然后转交给该网络设备。

### egress

出的流量会直接调用network stack交由route table。route table判断该数据包交由哪个网络设备处理，然后转交给该网络设备。

## 网络栈

Linux网络栈包括了：网卡（Network Interface）、回环设备（Loopback Device）、路由表（Routing Table）和 iptables 规则。对于一个进程来说这些要素，其实就构成了它发起和响应网络请求的基本环境。

## Namespace


## Bridge
在Linux中能够起到虚拟交换机作用的网络设备是网桥（Bridge）。在一般模式下，它是一个L2的转发设备，主要功能是根据MAC地址学习来将数据包转发到网桥的不同端口（Port）上。

但当它开启bridge-nf-call-iptables之后，就变成一个网卡模式。从任何一个port收到数据包之后，会调用网络栈交由route table进行路由判断，从而交给指定的网络设备处理（也可以交回给bridge本身）。

一旦一张虚拟网卡被“插”在网桥上，它就会变成该网桥的“从设备”。从设备会被“剥夺”调用网络协议栈处理数据包的资格，从而“降级”成为网桥上的一个端口。而这个端口唯一的作用，就是接收流入的数据包，然后把这些数据包的“生杀大权”（比如转发或者丢弃），全部交给对应的网桥。


## Veth Pair
Veth Pair设备的特点是：它被创建出来后，总是以两张虚拟网卡（Veth Peer）的形式成对出现的。
从其中一个“网卡”发出的数据包，可以直接出现在与它对应的另一张“网卡”上，哪怕这两个“网卡”在不同的namespace里。
这就使得Veth Pair常常被用作连接不同Network Namespace的“网线”。

## TUN

在 Linux 中，TUN 设备是一种工作在三层（Network Layer）的虚拟网络设备。TUN 设备的功能非常简单，即：在操作系统内核和用户应用程序之间传递 IP 包。以 flannel0 设备为例：当操作系统将一个 IP 包发送给 flannel0 设备之后，flannel0 就会把这个 IP 包，交给创建这个设备的应用程序，也就是 Flannel 进程。这是一个从内核态（Linux 操作系统）向用户态（Flannel 进程）的流动方向。反之，如果 Flannel 进程向 flannel0 设备发送了一个 IP 包，那么这个 IP 包就会出现在宿主机网络栈中，然后根据宿主机的路由表进行下一步处理，这是一个从用户态向内核态的流动方向。