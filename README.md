# Machine Learning (ML) Module

Machine learning is used in overt and covert ways throughout our lives, including in the educational contexts with which we are involved. Indeed, machine learning has a growing - but questionable - role in educational research and practice. What that role will be is up to us. In these learning labs, you will become familiar with machine learning and how it is used in educational contexts, especially for STEM education research. In particular, we'll explore four questions throughout this module:

1. Can we predict something we would have coded by hand?
1. How much do new predictors improve the prediction quality?
1. How much of a difference does a more complex model make?
1. What if we do not have training data?

## ML Learning Lab 1: Prediction

We have some data, but we want to use a computer to **automate** or scale up the relationships between predictor (independent) and outcome (dependent) variables. Supervised machine learning is suited to this aim. In particular, in this learning lab, we explore how we can train a computer to learn and reproduce qualitative coding we carried out---though the principles extend to other types of variables. We use *data from a large, social media-based community focused on supporting the implementation of the Next Generation Science Standards, #NGSSchat on Twitter*. Using 1000s of qualitative codes from two years of the chat, we explore how well a computer can scale up this coding so that we might be able to code data from the other eight years of the chat. Conceptually, we focus on understanding how prediction differs from explanation and why it is essential to split our data for supervised machine learning into "training" and "testing" sets.  

## ML Learning Lab 2: Feature Engineering

Once we have trained a computer in the context of using supervised machine learning methods, we may realize we can improve it by adding new variables or changing how the variables we are using were prepared. In this learning lab, we consider **feature engineering* *a variety of types of data from many online science courses* to predict students' success after only a few weeks of the course. In order to engineer and include features in our model and see how different the models' predictive performance is (without introducing bias by "over-fitting" our model to the data), we use cross-validation.

## ML Learning Lab 3: Model Tuning

Even with optimal feature engineering, we may be able to specify an even more predictive model by selecting and *tuning* a more sophisticated algorithm. While in the first two learning labs we used logistic regression as the "engine" (or algorithm), in this learning lab, we use a random forest as the engine for our model. This more sophisticated type of model requires us to specify **tuning parameters**, specifications that determine how the model works. In this learning lab, we again use the _#NGSSchat_ data set with the aim of seeing how much better we can predict the nature of the conversations taking place there with model tuning (and some of the feature engineering steps we took in the previous learning lab). We discuss the bias-variance trade-off as it relates to choosing between a more simple or complex model.

## ML Learning Lab 4: Unsupervised Methods

The previous three learning labs involved the use of data with known outcome variables (coded for the substantive or transactional nature of the conversations taking place through #NGSSchat in learning labs 1 and 3 and students' grades in learning lab 2). Accordingly, we explored different aspects of supervised machine learning. What if we have data without something that we can consider to be a dependent variable? **Unsupervised machine learning methods** can be used in such cases. In this learning lab, we explore the use of latent profile analysis as a way of estimating groups on the basis of a set of predictor variables. Using *data from the _ASSISTments adaptive mathematics tutoring tool_). At a conceptual level, we consider computational grounded theory as a way of integrating an approach such as latent profile analysis with qualitative methods as a means of leveraging the strengths of both machine learning and traditional analytic methods. 