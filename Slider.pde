class Slider{
	PVector pos 	= new PVector(0, 0);
	float ancho		= 300;
	float alto		= 38;
	float posicion 	= pos.x + ancho/2;
	float valor 	= 128;
	int diameter 	= 70;
	boolean isOver 	= false;
	boolean isMove	= false;
	boolean isTri	= false;
	PImage knob;
	PImage circulo;
	PImage slid;


	Slider(){}


	void setup(PVector newPos, float newAncho, float newAlto, String newImg){
		knob 		= loadImage("slider_Knob.png");
		circulo 	= loadImage("circulo.png");
		pos 		= newPos;
		ancho 		= newAncho;
		alto 		= newAlto;
		posicion 	= pos.x + ancho/2;
        calculaValor();
        slid 		= loadImage(newImg);
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
		if (isOver && touch > pos.x && touch < pos.x + ancho) {
			posicion = touch;
			calculaValor();
			isMove = true;
		}
	}

	void draw(){
		stroke(255);
		if (!isTri) {
			fill(150);
		}
		line(pos.x, pos.y + alto/2 , pos.x + ancho, pos.y + alto/2);
		if ((isOver || isMove) && isTri) {
				stroke(255);
				fill(0);
  				ellipse(posicion - 2.5, pos.y + 19, 45, 45);
			}
			if (!isTri) {
				tint(150, 100);
			}
			image(knob, posicion - 19, pos.y);
			image(slid, pos.x + ancho/2 - 15, pos.y - 50);
			tint(255, 255);
			isOver = false;
			isMove = false;	
	}

	boolean over(PVector touch){
		float disX = posicion -diameter/2 + alto/2 - touch.x;
  		float disY = pos.y + alto/2 - touch.y;
  		if (isTri && (sqrt(sq(disX) + sq(disY)) < diameter/2 || 
  			(touch.x > pos.x && touch.x < pos.x + ancho && touch.y > pos.y + alto/2 -diameter && touch.y < pos.y + alto/2 +diameter))) {
    		isOver = true;
  		} else {
    		isOver = false;
  		}
  		updatePos(touch.x);
  		return isOver;
	}

}