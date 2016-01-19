class Slider{
	PVector pos  = new PVector(0, 0);
	float valor    = 0;
	float posicion = 0;
	float diameter = 60;
	boolean isOver = false;
	boolean isMov = false;
	float longitud;
	PImage icono;
	PImage circulo;

	Slider(){}

	void setup(float newValor, PVector newPos, float newLongitud){
		icono 		= loadImage("slider_Knob.png");
		circulo = loadImage("circulo.png");
		valor 		= newValor;
		pos 		= newPos;
		longitud 	= newLongitud;
		posicion 	= pos.x;
		pos.y 		= pos.y - 19;
	}

	void setValor(int newValor){
		valor = newValor;
	}

	float getValor(){
		return valor;
	}

	void updatePos(PVector touch){
		if (isOver && touch.x > pos.x && touch.x < pos.x + longitud) {
			posicion = touch.x;
			isMov = true;
		}
	}

	void draw(){
		if (isOver || isMov) {
			image(circulo, posicion - 45, pos.y - 10, diameter, diameter);
		}
		image(icono, posicion - 33 , pos.y);
		isOver = false;
		isMov = false;
	}

	void calcularPosicion(){
		posicion = (longitud / 255.0) * valor;
	}

	void over(PVector touch){
		float disX = posicion - touch.x;
  		float disY = pos.y - touch.y;
  		//ellipse(posicion, pos.y, diameter, diameter);
  		if (sqrt(sq(disX) + sq(disY)) < diameter ) {

    		isOver = true;
  		} else {
    		isOver = false;
  		}
  		updatePos(touch);
	}

}