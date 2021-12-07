void robot_world_distances_init(double *u4,
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
                                      double *y7,
                                      double *y8,
                                      int  *work1,
                                      void *work2,
                                      void *work3,
                                      void *work4)
{
    
    /* Declarations */
    ClosestPairs *results;
    int ii;
    const double *links_point_a, *ee_point_a, *links_point_b, *ee_point_b;
    const double *links_axis_u, *ee_axis_u, *links_axis_v, *ee_axis_v, *links_radius, *ee_radius;
    int num_link_volumes, num_ee_volumes, num_world_volumes, num_tests;
    const bool *world_activation_flag;
    const double *world_p_min, *world_p_max, *world_frames;
    double *num_ee_volumes_out, *num_world_volumes_out;
    Robot *r;
    World *w;
    
    /* Obtain inputs */
    links_point_a         = u4;
    ee_point_a            = u5;
    links_point_b         = u6;
    ee_point_b            = u7;
    links_axis_u          = u8;
    ee_axis_u             = u9;
    links_axis_v          = u10;
    ee_axis_v             = u11;
    links_radius          = u12;
    ee_radius             = u13;
    world_p_min           = u14;
    world_p_max           = u15;
    world_frames          = u16;
    world_activation_flag = (bool *) u17;
    
    num_ee_volumes_out        = y7;
    num_world_volumes_out     = y8;
    
    /* calculate num_ee_volumes from the number of positive ee_radius */
    num_ee_volumes = 0;
    for (ii=0;ii<max_ee_volumes;ii++){
        if(ee_radius[ii]>0){
            num_ee_volumes = num_ee_volumes + 1;
        }
    }
    
    *num_ee_volumes_out = (double)num_ee_volumes;
    
    /* calculate num_link_volumes from the number of positive links_radius */
    num_link_volumes = 0;
    for (ii=0;ii<max_link_volumes;ii++){
        if(links_radius[ii]>0){
            num_link_volumes = num_link_volumes + 1;
        }
    }
    
    /* calculate num_world_volumes from the number of positive world_activation_flag*/
    num_world_volumes = 0;
    for (ii=0;ii<max_world_volumes;ii++){
        if(world_activation_flag[ii] == true){
            num_world_volumes = num_world_volumes + 1;
        }
    }
    
    *num_world_volumes_out = (double)num_world_volumes;
    
    num_tests = (num_link_volumes + num_ee_volumes)*(num_world_volumes);
    *work1 = num_link_volumes;
    
    /* Create a robot instance  */
    r = init_robot();
    /* Add the collision volumes for links and end-effector */
    for (ii=0; ii<num_link_volumes; ii++){
        r = add_cylinder(r, &links_point_a[ii*3], &links_point_b[ii*3], links_radius[ii], ii, &links_axis_u[ii*3], &links_axis_v[ii*3]);
    }
    for (ii=0; ii<max_ee_volumes; ii++){
        r = add_cylinder(r, &ee_point_a[ii*3], &ee_point_b[ii*3], ee_radius[ii], num_link_volumes + ii, &ee_axis_u[ii*3], &ee_axis_v[ii*3]);
    }
    
    /* Save robot pointer in pointer work vector PWork */
    work2 = (void *) r;
    
    /* Create the world */
    w = init_world();
    
    /* Add objects to world */
    for (ii=0; ii<max_world_volumes; ii++){
            w = add_cuboid(w, &world_frames[ii*16], &world_p_min[ii*3], &world_p_max[ii*3]);
    }
    
    /* Save world pointer in pointer work vector PWork */
    work3 = (void *) w;
    
    /* Allocate memory for result structure  */
    results=(ClosestPairs *)malloc(max_r2w_tests*sizeof(ClosestPairs));
    
    /* Initialize all result structure members to 0  */
    memset(results, 0, max_r2w_tests*sizeof(ClosestPairs));
    
    /* Save results in pointer work vector PWork */
    work4 = (void *) results;
    
    
}


void robot_world_distances_terminate( void *work2,
                                      void *work3,
                                      void *work4)
{
    /* Declarations */
    ClosestPairs *result;
    Robot *r;
    World *w;
    
    /* Free robot and world objects */
    r = (Robot*) work2;
    free_robot(r);
    w = (World*) work3;
    free_world(w);
    result = (ClosestPairs *) work4;
    free(result);
}