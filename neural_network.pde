// **** //
// CONSTANTS THAT DEFINE NETWORK
// **** //

int[] layers = {2,2,2};
int repeats = 2;

// **** //
// **** //
// **** //

int[] layers_in = new int[layers.length];
int[] layers_out = new int[layers.length];

node[][] network = new node[layers.length][];
connection[] network_in = new connection[layers[0]];
connection[] network_out = new connection[layers[layers.length-1]];

double[][] input = {
  {0.2, 0.8},
  {0.3, 0.5},
  {0.4, 0.2},
  {0.9, 0.8},
  {0.5, 0.6},
  {0.6, 0.3}
};

double[][] truth = {
  {1.0, 0.0},
  {0.0, 1.0},
  {0.0, 1.0},
  {1.0, 0.0},
  {1.0, 0.0},
  {0.0, 1.0}
};

int input_no = 0;
int repeat_no = 0;

int correct = 0;
int all = repeats * input.length;

double[] output = {0.0, 0.0};
double[] result = {0.0, 0.0};

void setup(){
  size(600,400); 
  
  layers_in[0] = 1;
  layers_out[layers.length-1] = 1;
  
  for( int k=0; k<layers.length-1; k++){
    layers_in[k+1] = layers[k];
    layers_out[k] = layers[k+1];
  }
  
  spawn_nodes();
  connect_nodes();
  io_def();  
}

void draw(){
  clear();
  
  set_input();
  simulate_network();
  get_output();
  get_result();
  //display_results();
  
  draw_network();  
  fix_network();
  reset_values();
  
  if( input_no+1 < input.length ) input_no++;
  else{
    if( repeat_no < repeats-1 ){
      if( repeat_no % 20 == 0 ) print("-");
      input_no = 0;
      repeat_no++; 
    }else{
      println("ACCUARACY: "+correct+"/"+all);
      stop();
    }
  }
}

void fix_network(){
  for( int k=0; k<layers[layers.length-1]; k++){
    node node_fix = network[layers.length-1][k];
    
    double cost = Math.pow(output[k] - truth[input_no][k], 2);
    int sign = 0; // -1 or +1
    
    if( truth[input_no][k] - output[k] > 0 ) sign = 1;
    else sign = -1;

    int index = 0;
    double[] weights = new double[node_fix.in.length];
    double min = Double.MAX_VALUE;

    for( int i=0; i<node_fix.in.length; i++){
      weights[i] = node_fix.in[i].weight * sign;
      if( weights[i] < min ){
        min = weights[i]; 
        index = i;
      } 
    }
    node_fix.in[index].weight += cost * sign;
    println(nf((float)cost * sign, 1, 2));
  }  
}

void reset_values(){
  for( int k=0; k<layers.length; k++){
    for( int i=0; i<layers[k]; i++){
      network[k][i].value = 0.0; 
    }
  }
  for( int k=0; k<output.length; k++){
    output[k] = 0.0;
    result[k] = 0.0;
  }
}

void simulate_network(){
  for( int k=0; k<layers.length; k++){
    for( int i=0; i<layers[k]; i++){
      process_node(network[k][i]);
    }      
  }
}

void process_node(node n){
  double sum = 0;
  
  for( int k=0; k<n.in.length; k++) sum += n.in[k].value; // GET ALL IN CONNECTIONS
  
  if( n.layer != 0 ) n.value = sigmoid_function(sum+n.bias);
  else n.value = sum;
  
  for( int k=0; k<n.out.length; k++) n.out[k].value = n.out[k].weight * n.value; // SEND TO ALL OUT CONNECTIONS
}

double sigmoid_function(double in){
  return Math.pow(Math.exp(1),in)/(Math.pow(Math.exp(1),in)+1);
}

class node{
  
  int layer;
  
  connection[] in;
  connection[] out;
  
  double bias;
  double value; // SUM(IN_VALUES)
  
  node(int layer){
    this.layer = layer;
    in = new connection[layers_in[layer]];
    out = new connection[layers_out[layer]];
    bias = 0;
  }
  
}

class connection{
  
  node n1, n2;
  
  double weight;
  double value; // WEIGHT * OUT
  
  connection(node n1, node n2, double weight){
    this.n1 = n1;
    this.n2 = n2;
    this.weight = weight;   
  } 
}

void io_def(){  
  for( int k=0; k<layers[0]; k++){
    connection temp = new connection(null, network[0][k], 1.0);
    network[0][k].in[0] = temp;
    network_in[k] = temp; 
  }
  for( int k=0; k<layers[layers.length-1]; k++){
    connection temp = new connection(network[layers.length-1][k], null, 1.0);
    network[layers.length-1][k].out[0] = temp;
    network_out[k] = temp; 
  }
}

void connect_nodes(){ 
  for( int k=0; k<layers.length-1; k++){
    for( int i=0; i<layers[k]; i++){
      for( int j=0; j<layers_out[k]; j++){
        connection conn = new connection(network[k][i],network[k+1][j],Math.random());     
        network[k][i].out[j] = conn;
        network[k+1][j].in[i] = conn;
      }      
    }
  }
}

void spawn_nodes(){
  for( int k=0; k<layers.length; k++){
    network[k] = new node[layers[k]];
    for( int i=0; i<layers[k]; i++){
      network[k][i] = new node(k); 
    }
  }
}

void draw_network(){
  float x, y, x1, x2, y1, y2;
  int x_offset = -12;
  int y_offset = 5;
  
  for( int k=0; k<layers.length-1; k++){
    for( int i=0; i<layers[k]; i++){
      for( int j=0; j<layers[k+1]; j++){
        x1 = ((float)(k+1)/((float)(layers.length+1)))*width;
        y1 = ((float)(i+1)/((float)(layers[k]+1)))*height;
        x2 = ((float)(k+2)/((float)(layers.length+1)))*width;
        y2 = ((float)(j+1)/((float)(layers[k+1]+1)))*height;
        
        stroke(30,30,240);
        line(x1,y1,x2,y2);
        String toText = nf((float)network[k][i].out[j].value, 1, 2);
        fill(255);
        text(toText, (x1+x2)/2, (y1+y2)/2+x_offset);
      }
    }
  }   

  for( int k=0; k<layers.length; k++){
    for( int i=0; i<layers[k]; i++){
      x = ((float)(k+1)/((float)(layers.length+1)))*width;
      y = ((float)(i+1)/((float)(layers[k]+1)))*height;
      
      fill(255);
      ellipse(x,y,25,25);
      fill(0);
      String toText = nf((float)network[k][i].value, 1, 2);
      text(toText,x+x_offset,y+y_offset);
    }
  }
}

void set_input(){ 
  for( int k=0; k<network_in.length; k++){
    network_in[k].value = input[input_no][k];   
  }
}

void get_output(){
  for( int k=0; k<network_out.length; k++){
    output[k] = network[layers.length-1][k].value; 
  }
}

void display_results(){
  println("------------------------------------");  
  println("INPUT: "+nf((float)input[input_no][0],1,2)+" "+nf((float)input[input_no][1],1,2));
  println("OUTPUT: "+nf((float)output[0],1,2)+" "+nf((float)output[1],1,2));
  println("--------");
  println("TRUTH: "+truth[input_no][0]+" "+truth[input_no][1]);
  println("RESULT: "+result[0]+" "+result[1]);   
}

void get_result(){
  double max = 0;
  int index = 0;
  
  for( int k=0; k<result.length; k++){
    if( output[k] > max ){
      max = output[k];
      index = k;
    }
  }
  
  result[index] = 1.0;
  if( result[index] == truth[input_no][index] ) correct++;
}
