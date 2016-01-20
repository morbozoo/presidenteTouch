class Slider{
	PVector pos 	= new PVector(0, 0);
	float ancho		= 300;
	float alto		= 38;
	float posicion 	= pos.x + ancho/2;
	float valor 	= 128;
	int diameter 	= 70;
	boolean isOver 	= false;
	PImage knob;
	PImage circulo;


	Slider(){}

	void setup(PVector newPos, float newAncho, float newAlto){
		knob 		= loadImage("slider_Knob.png");
		circulo 	= loadImage("circulo.png");
		pos 		= newPos;
		ancho 		= newAncho;
		alto 		= newAlto;
		posicion 	= pos.x + ancho/2;
        calculaValor();
	}

	void calculaValor(){
		valor = (posicion - pos.x) * (255 / ancho);
	}



	void setValor(int newValor){
		valor = newValor;
	}

	float getValor(){
		return valor;
	}

	void updatePos(float touch){
		if (isOver && touch > pos.x - 15 && touch < pos.x + ancho - 15) {
			posicion = touch;
			calculaValor();
		}
	}

	void draw(){
		stroke(255);
		line(pos.x, pos.y + alto/2, pos.x + ancho, pos.y + alto/2);
		if (isOver) {
			image(circulo, posicion -diameter/2 + alto/2, pos.y + alto/2 - diameter/2, diameter, diameter);
		}
		image(knob, posicion, pos.y);
		isOver = false;
	}

	boolean over(PVector touch){
		float disX = posicion - touch.x;
  		float disY = pos.y + alto/2 - touch.y;
  		if (sqrt(sq(disX) + sq(disY)) < diameter ) {

    		isOver = true;
  		} else {
    		isOver = false;
  		}
  		updatePos(touch.x);
  		return isOver;
	}

}