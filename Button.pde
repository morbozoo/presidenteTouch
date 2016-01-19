class Button{
	PVector pos 		= new PVector(0, 0);
	int sizeW 			= 60;
	int sizeH			= 70;
	boolean isOver 		= false;
	boolean locked 		= false;
	boolean isSelected 	= false;
	PImage img;
	PImage circulo;

	Button(){}

	void setImg(String newImg){
		img 	= loadImage(newImg);
		circulo = loadImage("circulo.png");
	}

	void setPos(PVector newPos){
		pos = newPos;
	}

	boolean over(PVector targetPos){
		if(targetPos.x > pos.x && targetPos.x < pos.x + sizeW
			&& targetPos.y > pos.y && targetPos.y < pos.y + sizeH){
			isOver = true;
		}else{
			isOver = false;
		}
		return isOver;
	}

	void lock(){
		locked = true;
	}

	void unlock(){
		locked = false;
	}

	void draw(){
		if(isOver || isSelected){
			image(img, pos.x + img.width/12, pos.y + img.height/12, img.width/3, img.height/3);
			image(circulo, pos.x, pos.y, circulo.width/2, circulo.height/2);
		}else{
			image(img, pos.x, pos.y, img.width/2, img.height/2);
		}
		isOver = false;
	}

	void select(){
		isSelected = true;
	}

	void deselect(){
		isSelected = false;
	}
}