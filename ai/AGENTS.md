## Introduction
This is a Capstone Project for NUS Computer Engineering CG4002. My project is an Augmented Reality game that is based on fruit ninja. The user will play this game through a phone where it can be a pseudo VR headset. The components are broken down to AR, Hardware, Communications and AI Hardware. I am in charge of the AI Hardware. I'm doing it as an AI Accelerator on an FPGA, using Ultra96. ESP32 are also used. IMU sensors are mounted on the users hands to track movements.

## How does the Game work
It is like fruit ninja. The game will randomly generate fruits, and specific fruits have specific shapes to cut. A possible example if it's an apple I have to cut in a circle, and if it's watermelon I cut in triangle or something. I'm open to suggestions to make my model easily detect shapes.
I want it to be able to do in one player or 2 player mode. In one player mode I just slash. But in 2 player mode another person can be able to throw bombs that I need to avoid.

## What my AI does
The user is supposed to slash fruits it sees. So my AI system will run on the Ultra96, and will be able to derive the type of movements a user makes. Right now my project needs to have 6 clear clusters. Right now I just need to have 6 different type of "slashing". So I'm thinking that I can have it like 4 different slashes. One throwing motion (in 2 player mode) for bombs, and some sort of gesture I do to "time slow" so fruits move significantly slower and easier to slash fruits.

## Overall workflow
I plan to make python first using tensorflow to generate h5 file. This will implement Convoluted Neural Network model. I need to convert this to h file which I will put into Vitis HLS where my C++ implementation together with the h file will give me my IP Block. From there I will somehow take this IP Block and connect it in Vivado or something, transfer it to Ultra96 and my model will run there.

## File Structure
/software is where all my local training and my python scripts will be for exporting parameters
/ultra96 is all the code to be ran on ultra96, for example the dma scripts and bit and hwh
/vitis_hls is all the code (mainly in c++) that will be ran in vitis hls to generate ip block

## Notes
This is for a school project, I'm open to suggestions to make things easier and you can also give me suggestions for other things as well as I'm learning.