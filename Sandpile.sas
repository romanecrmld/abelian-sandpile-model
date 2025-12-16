%macro GenerateSandpile(Longueur, Largeur, nbgrains);
proc iml;
	/*Initialize sand matrix*/
	Lo = &Longueur;
	La = &Largeur;
	sandpiles = j(Lo, La, 0); 
	N = &nbgrains;
	
	sandpiles[(Lo/2)+0.5, (La/2)+0.5] = sandpiles[(Lo/2)+0.5, (La/2)+0.5] + N; /*Add all grains to the center of the matrix*/
	do until (max(sandpiles) < 4); /* Redistribute to neighboring cells */
		idx = loc(sandpiles >= 4); /*Locate indices where number of grains >= 4 */
		if ncol(idx) > 0 then do;
			sandpiles[idx] = sandpiles[idx]- 4; /* Subtract 4 grains from the cells found */
			do i = 1 to ncol(idx); /* Redistribute to neighboring cells */
			x = ceil(idx[i] / La); /* Index row number */
			y = mod(idx[i]- 1, La) + 1; /* Index column number */
			
			/* Redistribute to top, bottom, left, right */
			if x > 1 then sandpiles[x-1, y] = sandpiles[x-1, y] + 1; /* Top */
			if x < Lo then sandpiles[x+1, y] = sandpiles[x+1, y] + 1; /* Bottom */
			if y > 1 then sandpiles[x, y-1] = sandpiles[x, y-1] + 1; /* Left */
			if y < La then sandpiles[x, y+1] = sandpiles[x, y+1] + 1; /* Right */
			end;
		end;
	end;
	
		/* Define matrices x, y and z for 3D graphics */
	x = repeat(t(1:Lo), 1, La); /* Coordinates x*/
	y = repeat(1:La, Lo, 1);
	z = shape(sandpiles, Lo*La, 1); /* Height in grains of sand*/
	/* Create the dataset from the matrix x, y, z*/
	create sandpiles3d var {"x" "y" "z"};
	append;
	close sandpiles3d;
	quit;
	
	proc g3d data=sandpiles3d; /* 3D graphics using PROC G3D */
	plot y*x=z / grid rotate=25 tilt=5; /* Rotate and tilt for 3D visualisation */
	title "Abelian Sandpile Model- 3D Surface";
	run;
%mend GenerateSandpile;

%GenerateSandpile(31, 31, 2**10);