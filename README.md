Trebuchet
=========

Trebuchet is a gem for distributed performance testing. It spins up
arbitrary ec2 micro servers, and does performance testing from them.

To set up trebuchet, install it normally with gem, then copy down the
trebuchet.yml.example and rename it trebuchet.yml. Then update it with
your revelvant information.

To run arbitrary load tests, you can use trebuchet from the command line

    trebuchet -s 5 -c 100 -t 20M http://www.example.com

    -s: Number of Servers to spin up
    -c: Number of Concurrent Users per Server
    -t: Amount of Time to run the test (ex. 10S, 5M, 1H)

When you run from the command line, Trebuchet will spin up the required
servers in your 

Alternatively, you can invoke Trebuchet's internal ruby classes to spin
up servers, and run multiple load tests then terminate all the servers
it spun up. It will not terminate any other servers you have running in
EC2.

