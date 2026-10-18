#pragma header

#define PI 3.14159265359

attribute float alpha;
attribute vec4 colorMultiplier;
attribute vec4 colorOffset;
uniform bool hasColorTransform;

uniform bool downscroll;
uniform bool isSustainNote;

uniform mat4 perspectiveMatrix;
uniform mat4 viewMatrix;

uniform float screenX;
uniform float screenY;

uniform float songPosition;
uniform float curBeat;
uniform float scrollSpeed;

uniform float strumID;
uniform float strumLineID;
attribute float noteCurPos;
attribute float vertexID;

#pragma modifierUniforms

mat4 rotation3d(vec3 axis, float angle)
{
	axis = normalize(axis);
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;

	return mat4(
		oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
		oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
		oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
		0.0,                                0.0,                                0.0,                                1.0
	);
}

void main(void)
{

	float x = 0.0;
	float y = 0.0;
	float z = 0.0;
	float a = 1.0;
	float angleX = 0.0;
	float angleY = 0.0;
	float angleZ = 0.0;
	float scaleX = 1.0;
	float scaleY = 1.0;
	float incomingAngleX = 0.0;
	float incomingAngleY = 0.0;
	float incomingAngleZ = 0.0;
	float curPos = noteCurPos;

	float rad = PI / 180.0;

	y -= curPos * 0.45 * scrollSpeed;

	#pragma modifierFunctions

	if (incomingAngleX == 0.0 && incomingAngleZ == 0.0)
	{
		y += curPos * 0.45 * scrollSpeed;
	}
	else
	{

		float radius = curPos * 0.45 * scrollSpeed;

		vec4 p = vec4(0.0, radius, 0.0, 1.0);
		p = rotation3d(vec3(1.0, 0.0, 0.0), incomingAngleX * rad) * rotation3d(vec3(0.0, 1.0, 0.0), incomingAngleY * rad) * rotation3d(vec3(0.0, 0.0, 1.0), incomingAngleZ * rad) * p;

		x += p.x;
		y += p.y;
		z += p.z;
	}

    openfl_Alphav = openfl_Alpha;
	openfl_TextureCoordv = openfl_TextureCoord;
    openfl_Alphav = openfl_Alpha * alpha * a;
    if (hasColorTransform)
    {
        openfl_ColorOffsetv = colorOffset / 255.0;
        openfl_ColorMultiplierv = colorMultiplier;
    }

	vec4 pos = openfl_Position;

	if (!isSustainNote)
	{
		pos.x -= screenX;
		pos.y -= screenY;

		vec4 p = vec4(pos.x * scaleX, pos.y * scaleY, 0.0, 1.0);

		p = rotation3d(vec3(1.0, 0.0, 0.0), angleX * rad) * rotation3d(vec3(0.0, 1.0, 0.0), angleY * rad) * rotation3d(vec3(0.0, 0.0, 1.0), angleZ * rad) * p;

		pos.x = p.x;
		pos.y = p.y;
		z += p.z;

		pos.x += screenX;
		pos.y += screenY;
	}
	else
	{

		pos.x -= screenX;
		pos.y -= screenY;

		vec4 p = vec4(pos.x * scaleX, pos.y, 0.0, 1.0);

		p = rotation3d(vec3(0.0, 1.0, 0.0), angleY * rad) * p;

		pos.x = p.x;
		pos.y = p.y;
		z += p.z;

		pos.x += screenX;
		pos.y += screenY;
	}

 	pos.x += x;
	if (downscroll)
		pos.y += y;
	else
		pos.y -= y;

	pos = openfl_Matrix * pos;
	pos.z = ((z) * 0.001 * 1.5);
	gl_Position = perspectiveMatrix * viewMatrix * pos;
}

