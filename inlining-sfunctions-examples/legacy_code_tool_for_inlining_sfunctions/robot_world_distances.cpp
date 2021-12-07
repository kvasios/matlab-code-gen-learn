#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include "robot_world_distances.h"

void robot_world_distances_out(       double *u1,
                                      double *u2,
                                      double *u3,
                                      double *u4,
                                      double *u5,
                                      double *u6,
                                      double *u7,
                                      double *u8,
                                      double *u9,
                                      double *u10,
                                      double *u11,
                                      double *u12,
                                      double *u13,
                                      double *u14,
                                      double *u15,
                                      double *u16,
                                      double *u17,
                                      double *y1,
                                      double *y2,
                                      double *y3,
                                      double *y4,
                                      double *y5,
                                      double *y6,
                                      double *y7,
                                      double *y8,
                                      int  *work1,
                                      void *work2,
                                      void *work3,
                                      void *work4,
                                      int  *work5,
                                      int  *work6,
                                      int  *work7)
{
    /* Declarations */
    ClosestPairs * result;
    double *robot_volume_frames, *ee_radius, *links_radius;
    bool *world_activation_flag;
    int num_link_volumes, num_ee_volumes, num_world_volumes;
    double *ee_point_a,*ee_point_b,*ee_axis_u,*ee_axis_v,*world_p_min,*world_p_max,*world_frames;
    Robot *r;
    World *w;
    int ii,cc;
    bool *cartesian_collision_volumes_change_detected, *EE_collision_volumes_change_detected;
    double *num_ee_volumes_out, *num_world_volumes_out;
    double *res_nr_closest, *res_distance, *res_p1, *res_p1_other, *res_p2, *res_p2_other;
    int num_tests;
    
    
    /* Obtain pointers to the input and output  */
    
    /* Obtain inputs */
    cartesian_collision_volumes_change_detected = (bool *)   u1;
    EE_collision_volumes_change_detected = (bool *)   u2;
    
    robot_volume_frames   = (double *) u3;
    
    ee_point_a            = (double *) u5;
    ee_point_b            = (double *) u7; 
    ee_axis_u             = (double *) u9; 
    ee_axis_v             = (double *) u11;
    ee_radius             = (double *) u13;
    
    world_p_min           = (double *) u14;
    world_p_max           = (double *) u15;
    world_frames          = (double *) u16;
    world_activation_flag = (bool *) u17;
     
    res_nr_closest        = (double *) y1;
    res_distance          = (double *) y2;
    res_p1                = (double *) y3;
    res_p1_other          = (double *) y4;
    res_p2                = (double *) y5;
    res_p2_other          = (double *) y6;
    
    num_ee_volumes_out        = (double *) y7;
    num_world_volumes_out     = (double *) y8;
    
    num_link_volumes = *work1;
    
    num_world_volumes = *work5;
    num_ee_volumes    = *work6;
    num_tests         = *work7;
    
    /* Obtain the pointers stored in PWork */
    r = (Robot*) work2;
    w = (World*) work3;
    result = (ClosestPairs *) work4;
    
    if (*cartesian_collision_volumes_change_detected){
    
        /* calculate num_world_volumes from the number of positive world_activation_flag*/
        num_world_volumes = 0;
        for (ii=0;ii<max_world_volumes;ii++){
            if(world_activation_flag[ii] == true){
                update_cuboid(w, &world_frames[ii*16], &world_p_min[ii*3], &world_p_max[ii*3],num_world_volumes);
                num_world_volumes = num_world_volumes + 1;
            }
        } 
        
        *num_world_volumes_out = (double)num_world_volumes;
        
        num_tests = (num_link_volumes + num_ee_volumes)*(num_world_volumes);
        
        *work5 = num_world_volumes;
        *work7 = num_tests;
        
    }
    
    if (*EE_collision_volumes_change_detected){
    
        /* calculate num_ee_volumes from the number of positive ee_radius */
        num_ee_volumes = 0;
        for (ii=0;ii<max_ee_volumes;ii++){
            if(ee_radius[ii]>0){
                num_ee_volumes = num_ee_volumes + 1;
            }
        }
    
        *num_ee_volumes_out = (double)num_ee_volumes;
        
        num_tests = (num_link_volumes + num_ee_volumes)*(num_world_volumes);
        
        *work6 = num_ee_volumes;
        *work7 = num_tests;
        
        /*Update current geometrical features for the End-Effector Volumes */
        for (ii=0; ii<num_ee_volumes; ii++){
            update_cylinder_geometry(r, &ee_point_a[ii*3], &ee_point_b[ii*3], ee_radius[ii], num_link_volumes + ii, &ee_axis_u[ii*3], &ee_axis_v[ii*3]);
        }
        
    }
    
    /* Robot-world tests */
    robot_world_distances(r, w, robot_volume_frames, result, max_ee_volumes-num_ee_volumes, max_world_volumes-num_world_volumes);
    
    /* Reset to 0 p2 and p2_other in case nr_closest went from 2 to 1 */
    for (ii=0; ii<num_tests; ii++){
        if (result[ii].nr_closest==1){
            result[ii].p2[0] = 0;
            result[ii].p2[1] = 0;
            result[ii].p2[2] = 0;
            
            result[ii].p2_other[0] = 0;
            result[ii].p2_other[1] = 0;
            result[ii].p2_other[2] = 0;
            
        }
        if (result[ii].nr_closest==0){
            result[ii].p2[0] = 0;
            result[ii].p2[1] = 0;
            result[ii].p2[2] = 0;
            
            result[ii].p2_other[0] = 0;
            result[ii].p2_other[1] = 0;
            result[ii].p2_other[2] = 0;
            
            result[ii].p1[0] = 0;
            result[ii].p1[1] = 0;
            result[ii].p1[2] = 0;
            
            result[ii].p1_other[0] = 0;
            result[ii].p1_other[1] = 0;
            result[ii].p1_other[2] = 0;
        }
        
    }
    
    /* Generate output */
    for (ii=0; ii<num_tests; ii++){
        res_nr_closest[ii] = (double) result[ii].nr_closest;
        res_distance[ii]   = (double) result[ii].distance;
        memcpy(res_p1 + 3*ii,        &(result[ii].p1),        3*sizeof(double));
        memcpy(res_p1_other + 3*ii,  &(result[ii].p1_other),  3*sizeof(double));
        memcpy(res_p2 + 3*ii,        &(result[ii].p2),        3*sizeof(double));
        memcpy(res_p2_other + 3*ii,  &(result[ii].p2_other),  3*sizeof(double));
    }
    
    /* Generate output */
    for (ii=num_tests; ii<max_r2w_tests; ii++){
        res_nr_closest[ii] = 0;
        res_distance[ii]   = 0;
        memset(res_p1 + 3*ii,        0,         3*sizeof(double));
        memset(res_p1_other + 3*ii,  0,         3*sizeof(double));
        memset(res_p2 + 3*ii,        0,         3*sizeof(double));
        memset(res_p2_other + 3*ii,  0,         3*sizeof(double));
    }
    
}


