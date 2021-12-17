## About the ML Model

For this step I've had to choose a dataset that was capable of generating a good amount of load on the CPU, and for that reason I'm using a image based dataset:

### 1. Dataset: [Fashion Mnist](https://github.com/zalandoresearch/fashion-mnist) from [Zalando Research](https://research.zalando.com/). 
Fashion-MNIST is a dataset of [Zalando](https://jobs.zalando.com/tech/)'s article images—consisting of a training set of 60,000 examples and a test set of 10,000 examples. Each example is a 28x28 grayscale image, associated with a label from 10 classes. *(source: https://github.com/zalandoresearch/fashion-mnist)*

This is a very cool dataset that  has a good amount of images, and also has a MIT license which perfect for a lab like this.

### 2. ML Model: Accuracy check
The code used for to build this model was based on this guide:https://machinelearningmastery.com/how-to-develop-a-cnn-from-scratch-for-fashion-mnist-clothing-classification/. The logic behind this ML model is pretty simple:
At first we download a set of images and train our model identifying what kind of clothing is that image based on their labels. This step tends to demand more from the processor:
The second step is to validate a set of images on our model:
Finally we check the accuracy of the second step:


#### 2.1 About the model
First the code loads the Fashion MNist images and split between training and test sets:
```python
def load_dataset():
    # load dataset
    print("Lendo as imagens...")
    (trainX, trainY), (testX, testY) = fashion_mnist.load_data()
    # reshape dataset to have a single channel
    trainX = trainX.reshape((trainX.shape[0], 28, 28, 1))
    testX = testX.reshape((testX.shape[0], 28, 28, 1))
    # one hot encode target values
    trainY = to_categorical(trainY)
    testY = to_categorical(testY)
    return trainX, trainY, testX, testY
```

Then adjust the pixel image format:
```python
def prep_pixels(train, test):
    # convert from integers to floats
    print("Ajustando os pixels das imagens...")
    train_norm = train.astype('float32')
    test_norm = test.astype('float32')
    # normalize to range 0-1
    train_norm = train_norm / 255.0
    test_norm = test_norm / 255.0
    # return normalized images
    return train_norm, test_norm
```

After that we built the model structure:
```python
def define_model():
    model = Sequential()
    model.add(Conv2D(32, (3, 3), activation='relu', kernel_initializer='he_uniform', input_shape=(28, 28, 1)))
    model.add(MaxPooling2D((2, 2)))
    model.add(Flatten())
    model.add(Dense(100, activation='relu', kernel_initializer='he_uniform'))
    model.add(Dense(10, activation='softmax'))
    # compile model
    opt = SGD(learning_rate=0.01, momentum=0.9)
    model.compile(optimizer=opt, loss='categorical_crossentropy', metrics=['accuracy'])
    return model
```

Finally we train the model and evalute the model's accuracy:
```python
def evaluate_model(dataX, dataY, n_folds=3):
    print("Treinando o modelo...")
    scores, histories = list(), list()
    # prepare cross validation
    kfold = KFold(n_folds, shuffle=True, random_state=1)
    # enumerate splits
    for train_ix, test_ix in kfold.split(dataX):
        # define model
        model = define_model()
        # select rows for train and test
        trainX, trainY, testX, testY = dataX[train_ix], dataY[train_ix], dataX[test_ix], dataY[test_ix]
        # fit model
        history = model.fit(trainX, trainY, epochs=3, batch_size=32, validation_data=(testX, testY), verbose=0)
        # evaluate model
        _, acc = model.evaluate(testX, testY, verbose=0)
        print('Acurácia do modelo > %.3f' % (acc * 100.0))
        # append scores
        scores.append(acc)
        histories.append(history)
    return scores, histories
```
The final step is define a function to call each step sequentially:
```python
def run_test_harness():
    # load dataset
    trainX, trainY, testX, testY = load_dataset()
    # prepare pixel data
    trainX, testX = prep_pixels(trainX, testX)
    # evaluate model
    scores, histories = evaluate_model(trainX, trainY)
```

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

7. Use the navigation bellow to go to the next step

[< ----- Back](../Step2/Step2.md)      |          [Home](../README.md)         |         [Next----- >](../Step4/Step4.md) 
