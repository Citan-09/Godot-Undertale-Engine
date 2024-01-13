extends Node

func triangle(x:float,period:float=1,amplitude:float=1,offset:float=0):
	return (4*amplitude/period) * abs(fposmod((x-offset)-period/4,period)-period/2)-amplitude
func sine(x:float,period:float=1,amplitude:float=1,offset:float=0):
	return sin((x-offset)*TAU/period)*amplitude
	
	
func returnrotationdeg(target:Vector2,from:Vector2) -> float:
	var lookatvector = from.direction_to(target)
	return rad_to_deg((Vector2.DOWN).angle_to(lookatvector))
