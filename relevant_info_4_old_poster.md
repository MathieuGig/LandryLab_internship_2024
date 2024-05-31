# Info pour la présentation de mon vieux poster:

* L’antifongique fait une inhibition allostérique des protéines de FKS1 et FKS2

Training samples : 261 \
Why more than 180 ? If DMS is only 9x20 ? \
We did DMS on nucleotide sequences. So mutations with a distance of 1 amino acids have more ways of happening.

Test sample : 46
How many features ? 58x 9 = 522

Cross validation of 5, so validation samples of around 50 like our test samples. And also it limits how much data the model sees, so less overfitting. We take best parameters on that.


Also evaluated training balanced accuracy, shows no overfitting for caspofungin.

Latest results (for caspo):
- Bal acc: 0.95
- MCC : 0.897
- ROC-AUC: 0.95 
