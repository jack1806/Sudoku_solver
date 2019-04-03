Note: "SUDOKU" is a registered trademark of NIKOLI Co., Ltd. (Japan)

%%%%% SHORT EXPLANATION %%%%%

    Connect a web camera, confirm settings in sudokuvideo_fn.m, then run
    >> sudokuvideo_fn.m
    and point the camera at a sudoku puzzle.

    Run sampleprocess.m in cell mode to see the algorithm.

%%%%% LONG EXPLANATION %%%%%


What this demo does:
    1. This attempts to identify the numbers in a sudoku puzzle using video
       input, and then solves the solution.
    2. Optionally, the solution may be overlayed on the original video.

What you will need:

    1. A plain web camera that does not have a lot of noise.
    2. A well focused image.
    3. Decent lighting, with no large shadows on the image.

What you need to do:
    First confim that you can solve puzzles:
    >> edit SUDOKU_PUZZLE1.txt
    >> mysudokusolver SUDOKU_PUZZLE1.txt

    Then do it using video:
    There are some parameters that need to be tuned in sudokuvideo_fn.m
    (see lines 3-18)
    Then run 
      >>sudokuvideo_fn.m
    Stop it using control-c, or close the figure.
    If you get an out of memory error, run imaqreset.

Notes:

    This will not work with every puzzle out there. It relies on the external
    box being very distinct, and the numbers having a particular type of font.
    You may need to do some experimenting to find one that works well.
    The MathWorks News&Notes from Nov 2009 with Cleve's Corner: MATLAB and Sudoku
    seems to work ok.

File list:
1. sudokuvideo_fn.m:  The main file which reads and preprocesses the video input.
2. identifynumbers_fun.m:  The file which tries to find the location and value of numbers in the puzzle, by comparing to template data.
2. drawgraph.m:  This receives a matrix M, calls sudoku_solver, and displays the solution in a table.
4. sudoku_solver.m:  This recieves a matrix M, and calculates the Sudoku solution.
5. solution2image.m: This makes the overlay image of from the solution
6. sudoku_fn_trace.m: This takes the image from solution2image, and overlays it on the original video
7. TEMPLATEDATA.mat: This is a file that has sample numbers