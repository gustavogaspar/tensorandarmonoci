## About the ML Model
This step was created by my friend [@dougsouzars](https://github.com/dougsouzars) since I'm not a Data Science expert. Thanks again for your help!

For this step I had to choose a dataset that was capable of generating a good amount of load on the CPU, and for that reason I'm using a image based dataset:

### 1. Dataset: [Fashion Mnist](https://github.com/zalandoresearch/fashion-mnist) from [Zalandro Research](https://research.zalando.com/). 
Fashion-MNIST is a dataset of [Zalando](https://jobs.zalando.com/tech/)'s article images—consisting of a training set of 60,000 examples and a test set of 10,000 examples. Each example is a 28x28 grayscale image, associated with a label from 10 classes. *(source: https://github.com/zalandoresearch/fashion-mnist)*

This is a very cool dataset that  has a good amount of images, and also has a MIT license which perfect for a lab like this.

### 2. ML Model: Accuracy check
The code used to build this model was based on this guide:https://machinelearningmastery.com/how-to-develop-a-cnn-from-scratch-for-fashion-mnist-clothing-classification/. The logic behind this ML model is pretty simple:
\
At first we download a set of images and train our model identifying what kind of clothing is that image based on their labels. This step tends to demand more from the processor:
\
The second step is to validate a set of images on our model:
\
Finally we check the accuracy of the second step:


### 3. Let's run our code

1. Create a file named model.py:
```bash
$ vi model.py
```
2. Paste the following code to the file: [model.py](./src/model.py)
4. Hit ```esc``` to exit the insert mode then ```:wq``` to save and exit from vi editor
5. Execute:
```vim
$ python model.py
```
6. Repeat the process on both machines and see the results


[< ----- Back](../Step2/Step2.md)        |          [Home](../README.md)         |         [Next----- >](../Step4/Step4.md) 
