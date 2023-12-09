layer_dir=layer

poetry export -o requirements.txt

rm -rf $layer_dir 
mkdir $layer_dir
mkdir $layer_dir/python

python -m pip install -t $layer_dir/python -r requirements.txt

cd $layer_dir
zip -r lambda_layer.zip .