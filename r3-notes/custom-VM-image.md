Create gallery

```
az sig create -g R3-Test --gallery-name R3Gallery
```

Get VM (to be used to create image) ID

```
az vm get-instance-view -g R3-Test -n azuredemo-main --query id
```

Create image definition _from VM with hyperVGeneration of V2_

```
az sig image-definition create -g R3-Test -r R3Gallery -i VanadiumDefinition -p VanadiumPublisher -f VanadiumOffer -s VanadiumSKU --os-type linux --os-state specialized --hyper-v-generation V2
```

Create image version

```
az sig image-version create -g R3-Test -r R3Gallery -i VanadiumDefinition --gallery-image-version 1.0.0 --managed-image "/subscriptions/2638b066-e087-4170-9a37-5d9763d78bce/resourceGroups/R3-Test/providers/Microsoft.Compute/virtualMachines/azuredemo-main"
```

Create VM from image definition

```
az vm create -g R3-Test -n VMName --image "/subscriptions/2638b066-e087-4170-9a37-5d9763d78bce/resourceGroups/R3-Test/providers/Microsoft.Compute/galleries/R3Gallery/images/VanadiumDefinition" --specialized
```

Delete image version _must be deleted before an image definition can be deleted_

```
az sig image-version delete -g R3-Test -r R3Gallery -i VanadiumDefinition -e 1.0.0
```

Delete image definition

```
az sig image-definition delete -i VanadiumDefinition -g R3-Test -r R3Gallery
```