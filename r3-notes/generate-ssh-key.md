#### Mac

Open a new Terminal window
Type ssh-keygen -b 4096 -t rsa 
You will be prompted to enter a filename. By default, your keys will be saved as id_rsa and id_rsa.pub. Simply press Enter to confirm the default - there is no need to change this unless you have multiple keys! (Note: if you would like to change the default filename, you'll need to include the complete file path)
When prompted, enter a passphrase.
This will created a hidden directory called .ssh that contains both your public (id_rsa.pub) and private (id_rsa.) key files. 

#### Windows

https://www.purdue.edu/science/scienceit/ssh-keys-windows.html 
