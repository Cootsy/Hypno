This is the main template for making a weight gain avatar. The file size should be small enough to upload on the Figura servers normally.

----------------
The script comes with a number of features! The big one being the ability to gain weight after eating food. The size gained depends on the hunger and absorption amount increase.
You can also use the Figura action wheel to increase/decrease/max out/reset your weight.
Eventually, you can get so massive that the ground shakes and your stomach makes quite a lot of noise~
Also, there may be a fun surprise feature for anyone feeling like being a mega blob~

----------------
Modifying this template will still require knowledge of how to use the modeling software (Blockbench) and how to script in LUA.
I suggest watching this tutorial series to gain an understanding of how making avatars works: https://www.youtube.com/watch?v=TKB0q0SmCBo&list=PLNz7v2g2SFA8lOQUDS4z4-gIDLi_dWAhl

The main "script.lua" file is where all weight gain code is stored.

The blockbench model is already set up with various template parts for the different stages of fat. You aren't required to use the number of weight stages as is, though you will need to modify the script to change the references to model part names if you want to add more.
Also keep in mind that changing the name of parts might cause it to break if you don't also change the name in the script.

For example, if you add a new weight stage, you'll need to add new lines to apply physics to the belly/butt/tail, toggle the model parts in the setWeightVariant(variant) function, scale the belly in the setWeight(amount) function, and reduce the movement of the limbs in the events.render(delta, context) function.