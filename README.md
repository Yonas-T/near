
# Developing Flutter Integration with Near Protocol

This document explains how I built a dart package for Near Protocol integration for flutter developers. It gives a description about the research I conducted, the resources I used and those that did not help me to do the integration.


## Overview

This dart package helps flutter developers to interact with near protocol with the functions exposed when they install the package on their flutter project. Near is a layer one blockchain protocol that is highly scalable, inexpensive, and relatively faster in execution. Developers can build dApps (decentralized applications) using this protocol.

Flutter is an open source framework for building multi-platform applications from a single codebase. So if any flutter developer wants to build a dApp using Near protocol, this package will serve as a prepared set of functions to easily interact with the protocol. The developer does not have to do it from the ground up to do the integration.

## Tech Stack

Since Flutter is a cross-platform framework, it sometimes needs the development of plugins (packages which include platform specific codes). When developing the package, I primarily used dart programming language since there is no need to specifically code platform specific functions. 

## Documentation References

While developing the package I used mainly the following resources;
Near RPC API documentation
Since flutter does not have any way to enable developers to install javascript libraries, I was not able to use the sdk (near-api-js). So I had to write my own codes to interact with the RPC API prepared.
The link for the documentation is https://docs.near.org/docs/api/rpc 
Near Api Js (the javascript library for Near Protocol)
Even Though I have not used the library in my package, I used the library documentation and the github repository to understand how they interact with the api.
The link for the documentation is https://docs.near.org/docs/api/javascript-library
NEAR-CLI 
I utilized the command line interface to see some responses and cross check the functionalities.

When starting the project I went through the following youtube videos and slides to help me understand more about the protocol.
Introductory slides about the Near Blockchain http://bit.ly/ncd-1-1d-slides 
A beginner tutorial video for web developers to build dApp using Near https://www.youtube.com/watch?v=m6LJUpPPHoE&t=2905s

This does not help to directly delve into development but it kind of gives a good fundamental understanding on how to develop a dApp (web based) with Near blockchain. 


## Project Structure

The project includes the integration with Near protocol in the following features
Authentication to Near account
Integration to View functions
Sending tokens
Integration to Change functions
Transferring Nfts
Note: The project does not integrate parsing contract functions.

## Challenges and Solutions

One of the major challenges in doing the integration with the protocol was not being able to use the library developed for dApp developers. The library is done in javascript and I am using Dart to develop the package. The solution I got for this challenge was to do all the steps needed to directly interact with the RPC API. I use the near-api-js library as a reference to do it.
The second one is the javascript libraries that the near-api-js uses (like BN.js and borsh.js) do not have an exact replica for Dart. So I was supposed to find a substitute for that. The solution I found for it was to use other dart packages developed by the community (like tweetNacl, crypto) to do the needed task.
