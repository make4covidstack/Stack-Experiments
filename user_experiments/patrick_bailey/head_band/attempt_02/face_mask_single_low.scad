$fn=100;

arch_distance = 170; //width of the mask buckle
radius_of_arch = 150;
band_thickness=1.0;
buckle_height= 24.0;
end_knub_size=2;
hook_width = 2;
hook_depth = 2;
hook_count = 4;

bed_size=[250,200];

number_to_print=1; //42 max


for(num=[1:number_to_print]){
  translate([radius_of_arch+bed_size[0]/2-30,0]){
    rotate(90){
      translate([0,(band_thickness+hook_depth+2)*num]){
        stacked_headbands(arch_distance,
                        radius_of_arch,
                        band_thickness,
                        buckle_height,
                        end_knub_size,
                        hook_width,
                        hook_depth,
                        hook_count);
      }
    }
  }
  
  color("#000000"){
    square(bed_size, center=true);
  }
}

module stacked_headbands(arch_distance,
                  radius_of_arch,
                  band_thickness,
                  buckle_height,
                  end_knub_size,
                  hook_width,
                  hook_depth,
                  hook_count){
            
  angle = 360*(arch_distance/(2*PI*radius_of_arch));
                    

  difference(){
    union(){
      linear_extrude(buckle_height){   
        union(){    
          difference(){
            union(){
              circle(radius_of_arch);
            }
           
            circle(radius_of_arch-band_thickness);
            rotate(90+angle/2){
              square(arch_distance);
            }
            
            rotate(-angle/2){
              square(arch_distance);
            }
            
            translate([0,-arch_distance]){
              square(2*arch_distance,center=true);
            }  
          }
          //Create knubs on end
          mirror_copy(){
            translate(
                 X_Y_from_radius_angle(
                     radius_of_arch, 
                     (90-angle/2))){
              circle(end_knub_size);
            }
          }
        }
      }
      
      //Create the knubs
      mirror_copy(){
        for(x=[1:hook_count]){
          rotate(-angle/2 + x*5){
            translate([0,
               radius_of_arch-band_thickness/2]){
              create_extension(buckle_height, 
                  hook_width, hook_depth);  
            }
          }
        }
      }
    }
    //end angle difference
    mirror_copy(){
      rotate(-angle/2){
        translate([0,radius_of_arch]){
          end_angle(buckle_height);
        }
      }
    } 
    
    //Create the knubs negative part
    mirror_copy(){
      for(x=[1:hook_count]){
        rotate(-angle/2 + x*5){
          translate([0,
             radius_of_arch-band_thickness/2-1,
             ]){
               create_extension_removal(
                   buckle_height, 
                   hook_width, hook_depth);  
          }
        }
      }
    } 
  }
}

//Calculate [X,Y] given radius and angle
function X_Y_from_radius_angle(radius, angle) =
   [radius*cos(angle),radius*sin(angle)];


module end_angle(buckle_height){
  left_adjust = -buckle_height/4;

  translate([0,buckle_height/2]){
    rotate([90,0,0]){
      linear_extrude(buckle_height){
        translate([left_adjust,0]){  
          polygon([
                  [0,0],
                  [buckle_height/3, 
                     buckle_height/3],
                  [buckle_height/3, 
                     2*buckle_height/3],  
                  [0,buckle_height],
                  [buckle_height/2,buckle_height],
                  [buckle_height/2, 0],
                  ]);
        }
      }  
    }
  }
}

module hook(buckle_height, hook_width,hook_depth){
  left_adjust=(hook_width/sin(45))/2;

  translate([0,hook_depth]){
    rotate([90,0,0]){
      linear_extrude(hook_depth){
        translate([-left_adjust,0,0]){
          polygon([
                  [0,0], 
                  [buckle_height/4*sin(45),
                         buckle_height/4*sin(45)],
                  [buckle_height/4*sin(45) 
                         + hook_width*sin(45),
                         buckle_height/4*sin(45)
                         - hook_width*sin(45)],
                  [hook_width/cos(45), 0],
                  ]);  
        } 
      }
    } 
  }
}

module create_extension(buckle_height, hook_width, hook_depth){
  
  mirror_copy_headband(){
    difference(){
      hook(1.5*buckle_height,
           1.5*hook_width,hook_depth);
      translate([-1.5*hook_width,
           2.1*1.5*hook_width]){
        rotate([45,0,0]){
          cube(buckle_height/2,buckle_height/2);
        }
      }
    }
  }
}

module create_extension_removal(buckle_height, hook_width, hook_depth){
  
  mirror_copy_headband(){
    hook(buckle_height,
           hook_width,6*hook_depth);
  }
}

//See https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Tips_and_Tricks#Create_a_mirrored_object_while_retaining_the_original
module mirror_copy(v = [1, 0, 0]) {
    children();
    mirror(v) children();
}

module mirror_copy_headband(v = [0, 0, 1]) {
    children();
    translate([0,0,buckle_height]){
      mirror(v) children();
    }
}