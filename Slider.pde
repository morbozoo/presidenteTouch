class Slider{
	PVector pos 	= new PVector(0, 0);
	float ancho		= 300;
	float alto		= 38;
	float posicion 	= pos.x + ancho/2;
	float valor 	= 128;
	int diameter 	= 70;
	boolean isOver 	= false;
	boolean isMove	= false;
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

	void setValor(float newValor){
		valor = newValor;
		posicion = pos.x + ((valor/255) * ancho);
	}

	float getValor(){
		return valor;
	}

	void updatePos(float touch){
		if (isOver && touch > pos.x - 15 && touch < pos.x + ancho - 15) {
			posicion = touch;
			calculaValor();
			isMove = true;
		}
	}

	void draw(){
		stroke(255);
		line(pos.x, pos.y + alto/2, pos.x + ancho, pos.y + alto/2);
		if (isOver || isMove) {
			stroke(255);
			fill(0);
  			ellipse(posicion + 16.5, pos.y + 19, 45, 45);
			//image(circulo, posicion -diameter/2 + alto/2, pos.y + alto/2 - diameter/2, diameter, diameter);
		}
		image(knob, posicion, pos.y);
		isOver = false;
		isMove = false;
	}

	boolean over(PVector touch){
		float disX = posicion -diameter/2 + alto/2 - touch.x;
  		float disY = pos.y + alto/2 - touch.y;
  		if (sqrt(sq(disX) + sq(disY)) < diameter || (touch.x > pos.x && touch.x < pos.x + ancho && touch.y > pos.y + alto/2 -diameter && touch.y < pos.y + alto/2 +diameter)) {
    		isOver = true;
  		} else {
    		isOver = false;
  		}
  		updatePos(touch.x);
  		return isOver;
	}

}