PROGRAM random_input
  USE geometry !Importing the geometry module
  USE particle !Importing the particle module 
  USE iso_fortran_env !Importing iso_fortran_env to specify the number of bits of the variables
  IMPLICIT NONE
  
  INTEGER(INT64) :: i, n !Integer variable for looping indexing  and number of bodies
  INTEGER(INT32) :: values(1:8), k !Variables for storing data and time info and holding the size of the random seed
  INTEGER(INT32), allocatable :: seed(:) !Random seed
  TYPE(particle3d), allocatable :: p(:) !Particles
  REAL(REAL64) :: rx, ry, rz, vx, vy, vz !Random coordinates for the position (x, y, z) and velocity (vx, vy, vz) of the particles
  REAL(REAL64) :: mass, M !Random mass of a particle and total mass of the particles
  REAL(REAL64) :: dt, t_end, dt_out, theta !Time step, final time, output time step and parameter that determines the accuracy of the simulation

  CHARACTER(len = 50) :: input  !Input file name for initial data
  INTEGER :: io_status !Variable to check the status of I/O operations

  !Read the input file name from the user
  PRINT*, "Insert the input file name: "
  READ*, input
  
  CALL date_and_time(values = values) !Get the current date and time
  CALL random_seed(size = k) !Get the size of the random seed

  !Allocate memory for the random seed
  ALLOCATE(seed(1:k))
  
  SEED(:) = values(8) !Initialize the random seed using the current date and time
  CALL random_seed(put = seed) !Set the random seed

  !Read the number of bodies from the user
  PRINT*, "Insert the number of bodies: "
  READ*, n

  !Read the time step from the user
  PRINT*, "Insert the time step: "
  READ*, dt
  
  !Read the output time step from the user
  PRINT*, "Insert the output time step: "
  READ*, dt_out

  !Read the final time from the user
  PRINT*, "Insert the final time: "
  READ*, t_end

  !Read theta from the user
  PRINT*, "Insert theta: "
  READ*, theta
  
  !Allocate memory for particles array
  ALLOCATE(p(n))

  !Initialize the total mass of the particles
  M = 0.0

  !Generate random masses and calculate the total mass of the particles
  DO i = 1, n
     CALL random_number(mass) !Generate a random number for the mass
     p(i)%m = mass !Assign the random mass to each particle
     M = M + mass  !Sum the contribution of the random mass to the total mass 
  END DO

  !Normalize the mass of the particles
  p%m = p%m/M

  !Open the input file and check for errors
  OPEN(12, file = input, status = 'replace', action = 'write', iostat = io_status)
  IF (io_status /= 0) THEN
      PRINT*, "Error opening file: ", input !Print error message if file opening fails
      STOP
   END IF

  WRITE(12, "(A9, 6X, 2A16, 5X, A18, 5X, A12)") "Time step", "Output time step", "Final time", "Number of bodies", "Theta" !Write header to the input file
  WRITE(12, "(ES12.6, ES15.6, 7X, ES15.6, I14, 15X, ES12.6)") dt, dt_out, t_end, n, theta !Write the time step, output time step, final time, number of bodies and theta to the input file

  WRITE(12, *) !Write a blank line
  
  !Write header for particles properties to the input file
  WRITE(12, "(A6, 1X, 7A12)") "Body", "Mass", "x", "y", "z", "vx", "vy", "vz"

  !Generate random positions and velocities for the particles
  DO i = 1, n
     DO
        CALL random_number(rx) !Generate a random number for the x-coordinate
        CALL random_number(ry) !Generate a random number for the y-coordinate

        IF ((NORM(vector3d(rx, ry, 0))**2) .LE. 1) EXIT !Ensure the generated coordinates are within a circle in the xy-plane
     END DO
     
     DO
        CALL random_number(rz) !Generate a random number for the z-coordinate
 
        CALL random_number(vx) !Generate a random number for the vx-coordinate
        CALL random_number(vy) !Generate a random number for the vy-coordinate
        CALL random_number(vz) !Generate a random number for the vz-coordinate

        p(i)%p = REAL(2.0, REAL64) * vector3d(rx, ry, rz) - point3d(1.0, 1.0, 1.0)  !Transform the range of values from (0, 1) to (-1, 1) for having also position negative values
        p(i)%v = REAL(2.0, REAL64) * vector3d(vx, vy, vz) - vector3d(1.0, 1.0, 1.0) !Transform the range of values from (0, 1) to (-1, 1) for having also velocity negative values
       
        IF ((NORM(vector3d(rx, ry, rz)))**2 .LE. 1) EXIT !Ensure the generated coordinates are within a sphere
     END DO

     WRITE(12, "(I6, 7X, 7ES12.4)") i, p(i)%m, p(i)%p, p(i)%v !Write the index, mass, position and velocity of each particle to the input file
  END DO

  CLOSE(12) !Close the input file

  PRINT*, "Initial data stored in file: ", input !End of program message
  
END PROGRAM random_input
