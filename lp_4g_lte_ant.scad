/***
 *  Log periodic antenna for 3G/4G/LTE based on Andrew McNeil's measurements
 *  in his YouTube(r) video "Log Periodic Antenna 3G 4G LTE 850MHz to 2.7GHz"
 *  https://www.youtube.com/watch?v=IgloDJYZKLI
 * 
 *  - Visualize antenna and parts
 *  - Generate drill template for drilling the boom (export pdf ...)

 *
 *  Current variable settings are based on materials that are
 *  easily and locally available to me:
 *  - Alfer(r) Aluminum extrusions
 *  - Metric fasteners
 *
 *  All measurements are Millimeters, I hope it's easily adaptable to
 *  your choice of materials
 * 
 * TODO/ ideas 
 *  - nec2 model (maybe)
 *  - maybe add log periodic antenna calculation
 *  - stub calculation
 *  
 ***/

$fn=32; //facets used for a circle or cylinder

/*
 visual_mode ( what to show when previewing or rendering)
 
 0 - nothing
 1 - render whole antenna
 2 - render one side (with tab)
 3 - boom template for center punch
     (render (F6) before converting to PDF ... check for scaling settings )
 8 - Shell (takes a while to render)
 9 - nec2 output to console
*/
visual_mode=1;


// Boom dimensions
boom_x = 300;
boom_y = 11.5;
boom_z = 2;
// spacing between booms 
boom_clearance = 5;

// where to start the first element.
element_offset_x = 10;
element_dia = 6;
element_hole_dia = 5 ;

coax_hole_dia = 2.5;
coax_hole_offset = 3;  // coax hole is offset from the end corner

mounting_hole = 5;
mounting_hole_offset1=10;
mounting_hole_offset2=30;

// elements run along x, and alternate direction as indicated by sign of z

element_xz = [
    [ 0,16 ],
    [ 5+3,-19],
    [ 15,25],
    [ 25+3,-35],
    [ 50,45],
    [ 77+3,-55],
    [ 112,65],
    [ 154+3,-75],
    [ 207, 90]
    ];

impedance_tab_hole_dia = 2.5;
impedance_tab_size = [13.5,25,1];
impedance_tab_offset = [ element_offset_x + element_xz[8][0] - (3.5 + 3 +impedance_tab_size[0]) ,boom_y/2 , -boom_z/2];
impedance_tab_hole_offset = 3;


module draw_impedance_tab( holes=0)
{
    if (holes > 0)
    {
        // offset from end of tab and tab thickness x 2??
        // check clearance for screw heads.
        translate([impedance_tab_hole_offset,-(impedance_tab_hole_offset + impedance_tab_size[2]),-boom_z-1])
        cylinder(d= holes==0 ? impedance_tab_hole_dia: holes , h = 10,center=true);
        translate([impedance_tab_size[0]-impedance_tab_hole_offset,-(impedance_tab_hole_offset + impedance_tab_size[2]),-boom_z-1])
        cylinder(d= holes==0 ? impedance_tab_hole_dia: holes , h = 10,center=true);
    }
    else
    {
        translate([impedance_tab_size[0],0,-impedance_tab_size[2] ])
        rotate([0,0,180])
        cube( size = impedance_tab_size+[0,-impedance_tab_size[1]+impedance_tab_hole_offset*2 ,0] );
        translate([-0,-impedance_tab_size,-boom_z])
        rotate([-90,0,0])
        //main part of tab
        cube(impedance_tab_size);
    }
}


// hole diameter
module draw_elements( holes=0 , text = 0 , nec2=0 )
{
    for ( i = element_xz)
    {
        
        rotate([ i[1]<0 && text==0 ? 180 : 0   ,0,0])
        translate([i[0],0, holes==0 ?  boom_z/2 : -boom_z/2-1 ])
        if (text == 0)
        {
            cylinder(h=abs(i[1]),d= (holes==0 ? element_dia : holes ) );
        }
        else
        {
            rotate([0,0,-60])
            text( str( i[1]," mm @ ",i[0] ," mm") , size=4, halign = "left", valign="center");
        }
        if (nec2 > 0)
            echo("NEC2 cards TODO?");
    }
}

// module draw antenna (or just bar with holes)
// center the bar on x and z axis
module draw_half_antenna(no_impedance_tab=0, impedance_tab=1, hole_dots=0 )
{
    difference()
    {
        union()
        {
            translate([0,-boom_y/2,-boom_z/2])
            cube(size = [boom_x,boom_y,boom_z], center = false);
            // elements
            //translate([element_offset_x,0,0])
            //draw_elements();
            if (no_impedance_tab==0)
            {
                // tab
                translate([element_offset_x,0,0])
                draw_elements();
                if (impedance_tab == 1)
                {
                    translate(impedance_tab_offset)
                    draw_impedance_tab();
                }
            }
        }
        translate([element_offset_x,0,0])
        draw_elements(holes = hole_dots==0 ? element_hole_dia : hole_dots);
        // tab holes2
        if (impedance_tab == 1)
        {
            translate(impedance_tab_offset)
            draw_impedance_tab(holes = hole_dots==0 ? impedance_tab_hole_dia : hole_dots );
        }
        // connection hole
        translate([coax_hole_offset,coax_hole_offset-boom_y/2,0])
        //rotate([90,0,0])
        cylinder(h=boom_z+1, d= hole_dots==0 ? coax_hole_dia : hole_dots , center=true);

        // mounting holes
        translate([boom_x-mounting_hole_offset1,0,0])
        cylinder(h=boom_z+1, d= hole_dots==0 ? mounting_hole: hole_dots, center=true);
        translate([boom_x-mounting_hole_offset2,0,0])
        cylinder(h=boom_z+1, d= hole_dots==0 ? mounting_hole: hole_dots, center=true);
        
    }  
}

//draw whole antenna
module draw_antenna()
{
    draw_half_antenna(impedance_tab=1);
    translate([0,-(boom_y + boom_clearance),0 ])
    rotate([180,0,0])
    draw_half_antenna(impedance_tab=0);
}


/*
  Render 2D projection of the boom that can be exported to a 2D format like
  pdf for use as a template.
  The booms are rotated so that bit so they will fit on an A4
*/

module boom_template()
{
    translate([-10,0,0])
    rotate([0,0,60])
    projection()
    translate([-150,0,0])
    draw_half_antenna(no_impedance_tab=1, hole_dots=0.25 );
    translate([10,0,0])
    rotate([0,0,60])
    projection()
    translate([-150,0,0])
    draw_half_antenna(no_impedance_tab=1, hole_dots=0.25);
    // text right
    translate([20,0,0])
    rotate([0,0,60])
    translate([-150,0,0])
    
    {
        translate([element_offset_x,0,0])
        draw_elements(text=1);
    //
        rotate([0,0,-60])
        translate([coax_hole_offset,0,0])
        //rotate([90,0,0])
        text( "coax connection" , size=4, halign = "left", valign="center");
    }
    // text left
    translate([-20,0,0])
    rotate([0,0,60])
    translate([-150,0,0])
    {
    // text left
        // tab holes2
        // mounting holes
        translate([boom_x-mounting_hole_offset1,0,0])
        rotate([0,0,-60])
        text( "mounting hole 1" , size=4, halign = "right", valign="center");
        translate([boom_x-mounting_hole_offset2,0,0])
        //cylinder(h=boom_z+1, d= hole_dots==0 ? mounting_hole: hole_dots, center=true);
        rotate([0,0,-60])
        text( "mounting holes 2" , size=4, halign = "right", valign="center");
        //
        translate(impedance_tab_offset)
        rotate([0,0,-60])
        text( "impedance tab holes x 2" , size=4, halign = "right", valign="center");

    }
}

/*
  visual_mode rendering
*/

if (visual_mode == 1 )
    translate([-150,0,0])
    draw_antenna();
if (visual_mode == 2 )
    translate([-150,0,0])
    draw_half_antenna(impedance_tab=1);
if (visual_mode == 3 )  boom_template();


// shell of antenna    
if (visual_mode == 8 ) 
{
    rotate([90,0,0])
    scale([1.2,1.2,1.2])
    //projection()
    hull()
    minkowski()
    {
        {
            rotate([90,0,0])
            draw_antenna();
        }
        cylinder(r=5,h=5,center=true);
    }
    //draw_antenna();
}
