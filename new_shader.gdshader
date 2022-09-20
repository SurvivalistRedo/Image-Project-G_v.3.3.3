shader_type canvas_item;

float variance(float time, float o1, float o2) {
	float sum = 0.0;
	for (float n = 0.0; n<=10.0; n++) {
		sum += sin(n*(time/10.0)-o1)+o2;
	}
	return sum;
}

float toggle(float x) {
	float output = 2.0*floor(2.0*mod(x/2.0,1.0))-1.0;
	if (output <= 1.0) {
		if (-1.0 <= output) {
			return output;
		}
	}
}

float ti(float x, float o) {
	return mod((x+o)*toggle(x+o),1.0);
}

float a(float x, float time) {
	float a = 1.0;
	float b = 0.0;
	
	return min(max((x+(a/2.0)-b)/a,0),1);
}

float f1(float time, float uvx, float uvy) {
	float i1 = uvx;
	float i2 = uvy;
	
	float f1m1 = ti(time,0.0)*2.0-1.0;
	float f1m2 = ti(time*1.1,1.0)*2.0-1.0;
	
	float f1o1 = 14.0*ti(time,0.0)-7.0;
	float f1o2 = 14.0*ti(time,0.5)-7.0;
	
	float f1b1 = ti(time,100.0);
	float f1b2 = ti(time,20.0);
	
	return a((((f1m1*i1+f1o1)*f1b1)+((f1m2*i2+f1o2)*f1b2)),time);
}

void fragment() {
	float t = TIME/10.0;
	float r =     f1(t+sin(t)/0.1, UV.x*50.0-25.0, 0.0-(UV.y*50.0-25.0));
	float g =     f1(t+cos(t)/0.1, UV.x*50.0-25.0, 0.0-(UV.y*50.0-25.0));
	float b = f1(t+sin(0.0-t)/0.1, UV.x*50.0-25.0, 0.0-(UV.y*50.0-25.0));
	float a =     f1(t-cos(t)/0.1, UV.x*50.0-25.0, 0.0-(UV.y*50.0-25.0));
	COLOR = vec4(r,g,b,1.0);
}