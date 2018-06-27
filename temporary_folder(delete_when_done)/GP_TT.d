/*    blah blah blah     */


#include <math.h>
#include <stdlib.h>
#include "pcsSocket.h"
#include "GLcommand.h"
#include "ldev_tst.h"
#include "decision_codes.h"


/*---------------- ANSI codes for colored text output ------------------------*/
#define ANSI_RED     "\x1b[31m"
#define ANSI_GREEN   "\x1b[32m"
#define ANSI_YELLOW  "\x1b[33m"
#define ANSI_BLUE    "\x1b[34m"
#define ANSI_MAGENTA "\x1b[35m"
#define ANSI_CYAN    "\x1b[36m"
#define ANSI_BOLD    "\x1b[1m"
#define ANSI_FAINT   "\x1b[2m"
#define ANSI_RESET   "\x1b[0m"

/*---------------------------- psychometric ----------------------------------*/
#define PSYCHOMETRIC

/*--------------------------- trial history ----------------------------------*/
#define HISTORY

#ifdef HISTORY
// will not reach this many trials
#define BUFSIZE 100000

int buf_coh[BUFSIZE] = {0};  // coherences
int buf_tgt[BUFSIZE] = {0};	 // stimulus directions
int buf_err[BUFSIZE] = {0};  // trial correct (=1) or incorrect (=0)
int buf_cnt		     = 0;    // number of trials added to buffers
int buf_wdw			 = 13;   // recall this many previous trials
#endif


/*----------------------------------------------------------------------------*/
#define PHOTO_RESET_BIT   Dio_id(PCDIO_DIO, 2, 0x04)
#define PHOTO_CELL_INPUT 0x1000

#define CBEVENT_PAUSEON    1010

#define WIND0 0   /* fixation window */
#define WIND1 1  /* target window */
#define WIND2 2  /* distractor window */
#define WIND3 3  /* target indicator window*/


#define PHOTO_RESET_BIT  Dio_id(PCDIO_DIO, 2, 0x4)					
/* bit 18 on the Kontron card */
#define PHOTO_CELL_INPUT 0x1
/* bit 0 on the Kontron card */
#define PHOTO_TRIG       1
#define START            1   /* for softswitch checking */
#define M_PI             3.141592653589793
#define NUM_DIFF         7  /*5*/  
#define NUM_ALTER        3   /* 2013-06-28 max number of alternatives */

#define GLASS_PATTERN        1   
#define GPOBJSTARTID         25
#define NUM_DIRECTION        2  


int photoTrigger, photoflag = 0;
 
int maxvtrials = 6000;       /*max num of trials,  0: infinite*/

/*Block design variables*/
int BLOCK_DESIGN  =   0;         /*block design flag*/       
int oldBLOCK_DESIGN = 0;         /*set it to be the same value as BLOCK_DESIGN at initialization*/                  
int changed =  0;      
int newblock = 1;
int numValidTrialperCond = 4;      /*number of correct trials per (non-zero) condition*/  
int currnumValidTrialperCond = 4;  /*!!!set it to be the same value as numValidTrialperCond at initialization*/
int numValidTrialperZeroCond = 2;   /*number of correct trials per zero coherence*/
int currnumValidTrialperZeroCond = 2;   /*!!!set it to be the same value as numValidTrialperZeroCond at initialization*/

/*Timing variables*/
int fmean_delay = 750;     /*Mean delay from ChoiceOn to CueOn*/
int logic_rand_cuePre = 1; /* Whether randomize the delay */

int	min_keepfpon_time = 50;         /*min fp on time after cue off in the delayed task*/
int max_keepfpon_time = 100;         /*max fp on time after cue off in the delayed task*/

int min_cueon_time = 700;        /*min cue on time after cue off in the delayed task*/
int max_cueon_time = 1200;        /*max cue on time after cue off in the delayed task*/
	 
long trange_sac2corr = 50;       /* time needed to hold on target to be considered as a correct trial*/
long time_to_reward = 600;      /* delayed task: for fixed time from FPoff to reward */ 

int urgencysig = 1200;          /* reaction time task: for fixed time from Cue onset to reward */ 

/*coherence variables*/
int difficulty;
int difficulty_buff; 
int numdiff = NUM_DIFF; 
int gp_cohvec[NUM_DIFF] = { 50, 36, 24, 17, 10, 5, 0}; 
int gp_cohcurr;

/* psychometric variables */
int n_trials[NUM_DIFF][2]	= {{0}};	/* valid trials */
int n_corr[NUM_DIFF][2]		= {{0}};	/* correct trials */


/*repeat error trial flags*/
int correctflag;
int repeatflag = 0;
int respflag;
int errorlevel;
int repeatswitch = 0;

/*receptive field x and y pos*/
int rfx = 75; /*83; *//*-77;*/					/* This determines the position of the target and direction of arrow */
int rfy = 75; /*56; *//*63 ;*/

// stimulus direction (0-based)
int idxstimdir;          /*0: right, 1:left*/
int idxtarloc;           /*0: left, 1:right*/

float lbias = 0.5f; /* Proportion of the time that left stimulus is presented (for reward clamp). For opposite direction bias or no bias, change to .3, .5 */
float oldlbias = 0.5f;


// for basic statistics
int nError = 0;
int nCorrect = 0;
int nTrial = 0; 
int vTrial = 0;

unsigned int lrvtrials[2]	 = {0};		// valid trials, per stim direction
unsigned int lrcorrectnum[2] = {0};		// correct trials, per stim direction

/* color of black background */
int backRed = 0;
int backGreen = 0;
int backBlue = 0;


/*for cover photodine*/
int background=0;  /*adjust*/

int nobjBar=1;
int objListBar=100;
float locXBar=0;
float locYBar=-10;
int barlength=260;
int barwidth=400;
int barcontrast=1;
int barorient=90;
int BarCovtag;           
int BarbackRed = 0;
int BarbackGreen = 0;
int BarbackBlue = 0;	


/*fixation point related parameters*/
float fixPtX = 0.0;
float fixPtY = 0.0;

int fpRed = 125;	   /* with all RGB values to be 255, the color is white */
int fpGreen = 125; 
int fpBlue = 125;    

int fpRedColor=125;

int fpClrCD = 1;

int fpdimRed;
int fpdimGreen;
int fpdimBlue;
int fpdimClrCD = 0; /* fp dim color: 0,white,1,red,2,green,3,blue,4,black */

int fp_diam = 3;          /*fixation point diameter*/

int fixOn = OBJ_ON;
int fixOff = OBJ_OFF;


/* Variables determining the properties of the 2 alternatives*/
int nObj = 2;					/* 1 target, 1 distractor */
int alterid[2] = {1,2}; /*  */
int tgRed[2] = {125,125};
int tsRed[2] = {255,255};
int tgGreen[2] = {125,125};
int tsGreen[2] = {255,255};
int tgBlue[2] = {125,125};
int bgBlack[2] = {0,0};

int tglum = 125;
int distlum = 125;

float Tx[2];
float Ty[2];
int tgsize = 6;       /*target diameter*/
int num_targ = 2;    /*1 means only one target, for training*/
int tgclrcd = 2;     /*1 white, 2 red*/
int outer[2];         /*target annulus outer diameter*/  
int inner[2] = {0, 0};   /*target annulus inner diameter*/  
int cntrst[2] = {1, 1}; /*FY int cntrst[2] = {1, 1}, for make distractor disappeared*/
int TGOn[2] = { OBJ_ON ,  OBJ_ON };
int TGOff[2] = { OBJ_OFF ,  OBJ_OFF }; 


/*Various eye window parameters*/
long wd_fp_diam = 30;     /* fixation window radius , half of the width*/
long wd_tg_diam = 45;      /* target window radius , half of the width*/
long wd_dist0_diam = 45;    /* distractor window radius, half of the width */
long wd_indicator_diam = 10;   /* target indicator window radius, half of the width */

/*eye signal variables*/
int eyeSignal = 0;
int eyeSignalSets[2][2] ={{0,1}, {2,3}};            /*0&1 represents left eye signals, 2&3 represents right eye signals*/
 
int tasktype = 2;       /*1:reaction time task 2: delayed task*/

int recGPMode = 1;      /*set GP stim record to 1*/
int nGPTrial = 0;       /*the No. of GP trial, starts from 1*/

int backcolorset(){
	BarCovtag=background;
	return(1);
}

 
int set_wndcheck()
{
    if (eyeSignal != 0 && eyeSignal != 1)
          eyeSignal = 0;                              /*set left eye signal as default*/
    wd_src_check(WIND0, WD_SIGNAL, eyeSignalSets[eyeSignal][0], WD_SIGNAL, eyeSignalSets[eyeSignal][1]);
    wd_src_check(WIND1, WD_SIGNAL, eyeSignalSets[eyeSignal][0], WD_SIGNAL, eyeSignalSets[eyeSignal][1]);
    wd_src_check(WIND2, WD_SIGNAL, eyeSignalSets[eyeSignal][0], WD_SIGNAL, eyeSignalSets[eyeSignal][1]);

    return (0);
}

int trialgate()									/* this variable will stop the program from running 
													after maxvtrails  - this can be set in a menu */
{
	if ((maxvtrials == 0) || (maxvtrials > vTrial))
		return(1);
	else
		return(0);
}


float randn;
float temprand[10] = {0.0, 0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9}; /*for shuffle using Yu20140130*/
void randnum()
{
    /*randn = rand() / (RAND_MAX +1.0);	*/ /*use the C built in rand num generator*/ 
	
    shuffle(10,10,temprand);  /* randomizing target location */	
	randn = temprand[1];

	return(0);
}



int targetloc;   /*Target location: 2 = left, 1 = right */
/*ecodes*/
int tgecode, dfecode;
int rfxecode, rfyecode;        /*ecodes for receptive field locations*/

double rotang;
int rotangd;

/*set stimulus features for fp, choices, GP coherence and direction for current trial*/
int setTGLocation()
{
   /*check whether block design parameter values changed*/
   if (BLOCK_DESIGN != oldBLOCK_DESIGN || numValidTrialperCond != currnumValidTrialperCond
      || numValidTrialperZeroCond != currnumValidTrialperZeroCond || lbias!=oldlbias)
   {
      changed = 1;
      oldBLOCK_DESIGN = BLOCK_DESIGN;
      currnumValidTrialperCond = numValidTrialperCond;
      currnumValidTrialperZeroCond = numValidTrialperZeroCond;
      oldlbias = lbias;
   }
   else 
      changed = 0;


	if (nTrial > 1)   
       difficulty_buff = difficulty;          /*save the difficulty level from the last trial*/
	   
    if (nTrial < 1)
        repeatswitch = 0;
   	else         /*decide whether to repeat the previous error trials or not based on the value of repeatflag and the type of error from the previous trial*/
    {	
        if (repeatflag == 0) 
           repeatswitch = 0;
        else if (repeatflag == 6)
        {
            if ((respflag == -5) || (respflag == -7) || (respflag == -3) || (respflag == -2) || (respflag == -4))  /*5 distracter, 7 fail to hold, 3 Anticipatory saccade*/
               repeatswitch = 1;
            else
               repeatswitch = 0;
        }
        else if (repeatflag == 5)
        {
          if ((respflag == -7) || (respflag == -3))  /* 2013-05-23, Anticipatory & Fail to hold*/
              repeatswitch = 1;
          else
             repeatswitch  = 0;       
        }    
        else if (repeatflag == 4)
        {
          if ((respflag == -7) || (respflag == -3) || (respflag == -2)) /* Any error except error choice 2013-05-06*/
              repeatswitch = 1;
          else
              repeatswitch  = 0;         
        }  
        else if (repeatflag == 3)
        {
          if ((respflag == -5) || (respflag == -7) || (respflag == -3) || (respflag == -2))  /*5 distracter, 7 fail to hold, 3 Anticipatory saccade*/
             repeatswitch = 1;
          else
             repeatswitch  = 0;     
        }
        else if (repeatflag == 2)
        {
          if ((respflag == -5) || (respflag == -7) || (respflag == -2))  /*5 distracter, 7 fail to hold*/
             repeatswitch = 1;
           else
              repeatswitch  = 0;                
        }
        else if (repeatflag == 1)
        {
            if ((respflag == -5) || (respflag == -2)) /* Only repeat wrong choice!*/
              repeatswitch = 1;
            else
              repeatswitch = 0;
        }          
    }
	
    if (repeatswitch == 1)        /*repeat the last error trial*/
        difficulty = difficulty_buff;       /*use the same difficulty level of previous trial*/
    else                   /*new trial*/
    {
		if (BLOCK_DESIGN != 1)
        {
		      randnum();
			  int a;
		      for (a = 0; a < numdiff; a++)
		      {
			     if (randn >= ((float)a / (float)numdiff) && randn < ((float)(a+1) / (float)numdiff))
			     {
				   difficulty = a;
				   break;
				 }
			  }
	        randnum();
	        if ((randn >= 0) && (randn < lbias)) 		  
	             targetloc = 2;                 /*Left*/
	        else
	             targetloc = 1;                 /*Right*/
        }			  
        else     /*block design, XQ*/
        {
            ShuffleTrial();      /*block design, decides difficulty level and targloc of next trial*/
        }
	}
	
    gp_cohcurr = gp_cohvec[difficulty];		
	
	
	if (targetloc == 2) 
		idxtarloc = 0;  /*target is on the left  */
	else
		idxtarloc = 1;   /*target is on the right */
	
	// 0-based stim direction, 0 = right, 1 = left
	idxstimdir = 1 - idxtarloc;
	
	tgecode = 4002 - targetloc;    /* target location ecode, 4000--left, 4001--right*/
	dfecode = 4100 + difficulty;   /* difficulty level ecode*/ 

	rfxecode = 7500 + rfx;    /*  rfx roughly ranges from -200 to 200 --> rfxecode ranges from 7300- 7700*/
	rfyecode = 8500 + rfy;     /* rfy roughly ranges from -200 to 200 --> rfyecode ranges from 8300- 8700*/ 

	
	/*Set X and Y position of the target and distractor window*/
	if (targetloc ==2)          /* target is on the left*/
    {
	     Tx[0] = (float)-abs(rfx);        /*X pos of the target window*/
	     Tx[1] = (float)abs(rfx);         /*X pos of the distractor window*/
	    }
	else                        /* target is on the right*/
	{
	     Tx[0] = (float)abs(rfx);         /*X pos of the target window*/
	     Tx[1] = (float)-abs(rfx);        /*X pos of the distractor window*/
	}
	
	if (rfx == 0)
	{
	     if (targetloc == 2)      /*target is on the left,  or down if the targets are on the vertical direction*/
	     {
	         Ty[0] = (float)-abs(rfy);            /*Y pos of the target window*/
	         Ty[1] = (float)abs(rfy);             /*Y pos of the distractor window*/
	      }
	     else     /*target is on the right, or up if the targets are on the vertical direction*/
	     {
	         Ty[0] = (float)abs(rfy);              /*Y pos of the target window*/
	         Ty[1] = (float)-abs(rfy);             /*Y pos of the distractor window*/
	      }	      
	  }
	else
	{
	    Ty[0] = Ty[1] = (float)rfy;
	 }
	
	
     /*target color*/ 
     tgRed[0] = tglum;
     tgGreen[0] = tglum; 
     tgBlue[0] = tglum; 
     
     /*distractor color*/
     tgRed[1] = distlum; 
     tgGreen[1] = distlum;
     tgBlue[1] = distlum;     
     
     if (tgclrcd == 2)         /*target color is red*/
     {
       tgGreen[0] = tgGreen[1] = tgBlue[0] = tgBlue[1] = 0;     
     }
    
	/*set target size*/
    if (num_targ == 1)
    {
          outer[0] = tgsize;
          outer[1] = 0;      
    }    
    else if (num_targ == 2)
    {
       outer[0] = outer[1] = tgsize;
    }
    
	
	/*calculate GP angles based on rfx and rfy*/
	if (idxtarloc == 0)       /*left*/
	{
   	   if (rfx == 0)
             rotang = M_PI*3.0f/2.0f;    /*down if the target is on the vertical direction*/
	   else if (rfy == 0)
	        rotang = M_PI;
       else 
          rotang = M_PI - atan((double)abs(rfy)/(double)abs(rfx));
    }
	else                       /*right*/
	{
   	   if (rfx == 0)
             rotang = M_PI/2.0f;       /*up if the target is on the vertical direction*/
	   else if (rfy == 0)
	        rotang = 0;
       else 
          rotang = atan((double)abs(rfy)/(double)abs(rfx));
	}
	
	double pi = M_PI;
    rotangd =  floor(rotang/pi*180.0); 
	
	/*print out stim coherence and direction info*/
	switch(idxtarloc)
	{
		case 1:		// right
						
			printf(ANSI_BOLD);
			printf("\nCoh = %3d, Stim = RIGHT\n", gp_cohcurr);
			printf(ANSI_RESET);

			break;
		case 0:		// left
			
			printf(ANSI_BOLD);
			printf("\nCoh = %3d, Stim = LEFT\n", gp_cohcurr);
			printf(ANSI_RESET);
			
			break;
	}

	
    /*Set fixation point color*/
	switch(fpClrCD)
	{
	case 0:    /*White or grayscale*/
		{
			fpRed = fpGreen = fpBlue = 125; 
			break;
		}
	case 1:   /*Red*/
		{
			fpRed = fpRedColor; 
			fpGreen = 0;
			fpBlue = 0;
			break;
		}
	case 2:   /*Green*/
		{
			fpRed = 0;
			fpGreen = 255;
			fpBlue = 0;
			break;
		}
	case 3:   /*Blue*/
		{
			fpRed = 0;
			fpGreen = 0;
			fpBlue = 255;
			break;
		}
	case 4:    /*Black*/
		{
			fpRed = fpGreen = fpBlue = 0;
			break;
		}
	}

	/*Set fixation point dim color*/
	switch(fpdimClrCD)
	{
	case 0:
		{
			fpdimRed = fpdimGreen = fpdimBlue = 255;
			break;
		}
	case 1:
		{
			fpdimRed = 255;
			fpdimGreen = 0;
			fpdimBlue = 0;
			break;
		}
	case 2:
		{
			fpdimRed = 0;
			fpdimGreen = 255;
			fpdimBlue = 0;
			break;
		}
	case 3:
		{
			fpdimRed = 0;
			fpdimGreen = 0;
			fpdimBlue = 255;
			break;
		}
	case 4:
		{
			fpdimRed = fpdimGreen = fpdimBlue = 0;
			break;
		}
	}

	nGPTrial = nTrial + 1;
	
	return(0);
}


/*glass pattern variables*/
int nGlassPattern = GLASS_PATTERN;		/* total number of glass pattern */
int glassObjects[GLASS_PATTERN];
float glassXLocs[GLASS_PATTERN];
float glassYLocs[GLASS_PATTERN];
int onGlassSwitches[GLASS_PATTERN]; 
int offGlassSwitches[GLASS_PATTERN]; 
int glassSwitchesex[GLASS_PATTERN];
typedef struct {
    char pattype;    /*pattern type*/
    int nf;          /*number of frames that have different sets of dots */
    float nr;		 /*number of rows of the pattern in visual angle     */
    float nc;        /*number of columns of the pattern in visual angle  */
    int ndots;       /*number of dots*/
	float dotsize;   /*dotsize in visual angle*/
	long int seed;   /*seed, seed=0 means using current time as seed*/
    int	dwell;       /*dwell, the number of frames that maintain the same dot set, dwell=1 means a new set of dots for each frames*/
    int dt;          /*delta of frames, i.e., dot pair distance between frames, dt=0 means dot pairs appear in the same frame */
    float dotamp;    /*brightness of dots (0-1), 1 means white */
    float dotbg;     /*brightness of background, not used, so just set it to be 0 */
    float percoh;    /*perentage of coherence 0-100*/
    int ang;         /*angle of dots */
    float r;         /*dot separation in visual angle*/
    float wander;    /*wander, only needed for pattern type '9' only, for all other pattern type, just give it any number*/
    int framerate;   /*number of frames per second*/
    int cycle;       /*repeat cycles of the movie*/
} GLASS_LIST;
GLASS_LIST glassList[] = {
/*   pattype nf nr nc ndots dotsize seed dwell dt dotamp dotbg percoh ang r wander framerate cycle*/
	{'t', 120, 6, 6, 15, 0.1, 0, 1, 0, 1, 0, 100, 45, 0.4, 0, 85, 10}
	/*{'o', 30, 20, 20, 2000, 0.2, 56564, 1, 0, 1, 0, 100, 0, 0.5, 0, 10, 100}*/
/* this array needs to be filled to the number of GLASS_PATTERN */
};
GLASS_LIST *glp = &glassList[0];
char glasspattype[GLASS_PATTERN];
int glassframes[GLASS_PATTERN];
float glassnr[GLASS_PATTERN];
float glassnc[GLASS_PATTERN];
int glassndots[GLASS_PATTERN];
float glassdotsize[GLASS_PATTERN];
long int glassseed[GLASS_PATTERN];
int glassdwell[GLASS_PATTERN];
int glassdt[GLASS_PATTERN];
float glassdotamp[GLASS_PATTERN];
float glassdotbg[GLASS_PATTERN];
float glasspercoh[GLASS_PATTERN];
int glassang[GLASS_PATTERN];
float glassr[GLASS_PATTERN];
float glasswander[GLASS_PATTERN];
int glassmovieframerate[GLASS_PATTERN];
int glassmoviecycle[GLASS_PATTERN];
/*Glass Mask Objects*/
int glassmaskObjects[GLASS_PATTERN];
typedef struct {
    float sw;       /* Width of the mask in visual angle */
    float sh;       /* Height of the mask is visual angle, sh = 0 means a round mask, and sw represents the diameter of the mask*/
    int sx;         /* X coordinate of the center of the mask*/
    int sy;         /* Y coordinate of the center of the mask*/
} GLASSMASK_LIST;
GLASSMASK_LIST glassMaskList[] = {
/*  sw sh sx sy */
	{6, 0, 0, 0}
	/*{10, 0, 0, 0}*/
/* this array needs to be filled to the number of GLASS_PATTERN */
};
GLASSMASK_LIST *glm = &glassMaskList[0];
float glassmasksw[GLASS_PATTERN];
float glassmasksh[GLASS_PATTERN];
int glassmasksx[GLASS_PATTERN];
int glassmasksy[GLASS_PATTERN];

/*GP parameters that can be changed through the menu*/
float apt_xpos = 0.0f;
float apt_ypos = 0.0f;
int nf1=120;          /*number of frames that have different sets of dots */
float nr1=6;		 /*number of rows of the pattern in visual angle     */
float nc1=6;        /*number of columns of the pattern in visual angle  */
int ndots1=15;       /*number of dots*/
float dotsize1=0.1;   /*dotsize in visual angle*/
int dwell1=1;       /*dwell, the number of frames that maintain the same dot set, dwell=1 means a new set of dots for each frames*/
int dt1=0;          /*delta of frames, i.e., dot pair distance between frames, dt=0 means dot pairs appear in the same frame */
float dotamp1=1;    /*brightness of dots (0-1), 1 means white */
float dotbg1=0;     /*brightness of background, not used, so just set it to be 0 */
float r1=0.4;         /*dot separation in visual angle*/
float wander1=0;    /*wander, only needed for pattern type '9' only, for all other pattern type, just give it any number*/
int framerate1=85;   /*number of frames per second*/
int cycle1=10;       /*repeat cycles of the movie*/
float sw1=6;       /* Width of the mask in visual angle */
float sh1=0;       /* Height of the mask is visual angle, sh = 0 means a round mask, and sw represents the diameter of the mask*/
int sx1=0;         /* X coordinate of the center of the mask*/
int sy1=0;         /* Y coordinate of the center of the mask*/

int orientSet=135; 
int GPorient; 
int openGPorient=1; /*=0, use target's location to define the orientation of the GP*/
int oriencode;
int trialcode;

/*initialize the GP parameters for current trial*/
int initialize()
{
	/*20140528 for GP orientation can be changed without relating to the target's location*/
	/*use the previous ange 'rotangd' to update the left or right side of the GP orientation.*/
	GPorient=rotangd;
	
    if (openGPorient==1) {
		if(orientSet>=0&&orientSet<=90){            /*target location y is positive*/
			if(rotangd>=0&&rotangd<=90)             /*right*/
				GPorient=	orientSet;
			else                                    /*left*/
				GPorient=	orientSet+90;
		}
		if(orientSet>90&&orientSet<=180){            /*target location y is negative*/
			if(rotangd>=0&&rotangd<=90)              /*right*/
				GPorient=	orientSet + 90;
			else                                     /*left*/
				GPorient=	orientSet;
		}		
	}
	
	oriencode=10000+GPorient; /* GP orientation code, if by 6000, for 6135, cerebus pause on, so 20140704 use 10000 */
	trialcode=20000+nTrial +1; /* trial index code; %20140616-Xueqi recommends to start with 1 */
			
	
	int i; 
	/*Set GP parameters*/
    for (i=0; i<nGlassPattern; i++)
	      onGlassSwitches[i]=OBJ_ON;
    for (i=0; i<nGlassPattern; i++)
	      offGlassSwitches[i]=OBJ_OFF;     
	for(i = 0; i < nGlassPattern; ++i) 
	{
	     glp = &glassList[i];
	  	 glassXLocs[i] = apt_xpos;
		 glassYLocs[i] = apt_ypos;

         glasspattype[i] = glp->pattype;
         glassframes[i] = nf1;
         glassnr[i]=nr1;
         glassnc[i] = nc1;
         glassndots[i]=ndots1;
         glassdotsize[i] = dotsize1;
         glassseed[i] = glp->seed;
         glassdwell[i]=dwell1;
         glassdt[i]=dt1;
         glassdotamp[i]=dotamp1;
         glassdotbg[i]=dotbg1;
         glasspercoh[i]=gp_cohcurr;            /*glasspercoh[i]=percoh1;*/
         glassang[i]=GPorient;                 /*glassang[i]=rotangd;    or  glassang[i]=ang1;*/
         glassr[i]= r1;
         glasswander[i]=wander1;
         glassmovieframerate[i] = framerate1;
         glassmoviecycle[i]=cycle1;
  		 glassObjects[i] = i + GPOBJSTARTID;             /*glass pattern object ids, change this to whatever number you need*/ 
	     glassSwitchesex[i] = i + GPOBJSTARTID;          /*glass pattern object ids for switching off*/ 
	}
    /*Set GP mask parameters*/	
	for(i = 0; i < nGlassPattern; ++i) 
	{
   	      glm = &glassMaskList[i];
	      glassmasksw[i]=sw1;
	      glassmasksh[i]=sh1;
	      glassmasksx[i]=sx1;
	      glassmasksy[i]=sy1;
	      glassmaskObjects[i]= i + GPOBJSTARTID;          /*glass pattern object ids for masking, same as glass pattern object ids*/ 
    }

	return(0);
}

/*shuffle the order of an array, used by block design */
void shuffleOrder(int *array, size_t n)
{
    if (n > 1) 
    {
        size_t i;
        for (i = 0; i < n - 1; i++) 
        {
          size_t j = i + rand() / (RAND_MAX / (n - i) + 1);   /*randnum(), randn*/
          int t = array[j];
          array[j] = array[i];
          array[i] = t;
        }
    }
}

int pickedTrialinBlock;
int numValidTrials[NUM_DIRECTION*NUM_DIFF] = {0};
int numLeftTrialperCond;
int numRightTrialperCond;
int numLeftTrialperZeroCond; 
int numRightTrialperZeroCond; 


/*Block design, randomly pick GP coherence level and GP direction for current trial */
void ShuffleTrial()
{
      int i,j, k;
	  int corrnumpercond;

      if (changed == 1 || newblock == 1)          /*start a new block*/
      {
      	    for (i=0; i<NUM_DIRECTION*NUM_DIFF; i++)
		         numValidTrials[i] = 0;
      }

	  numLeftTrialperCond = (int)floor(currnumValidTrialperCond * lbias);
	  numRightTrialperCond = currnumValidTrialperCond - numLeftTrialperCond; 
	  
	  numLeftTrialperZeroCond = (int)floor(currnumValidTrialperZeroCond * lbias);
	  numRightTrialperZeroCond = currnumValidTrialperZeroCond - numLeftTrialperZeroCond; 
      int *unpickedArr;
      if (currnumValidTrialperCond >= currnumValidTrialperZeroCond)
          unpickedArr = (int *)malloc(currnumValidTrialperCond*NUM_DIFF*sizeof(int)); 
      else
          unpickedArr = (int *)malloc(currnumValidTrialperZeroCond*NUM_DIFF*sizeof(int)); 

	 int totNum[NUM_DIRECTION];
	 int totalNums = 0;
     for (i=0; i<NUM_DIRECTION; i++)
     {
		   totNum[i] = 0;
		   for (j=0; j<NUM_DIFF; j++)
		   {
		       int indx = i*NUM_DIFF+j;
			   if (i == 0)          /*Left*/
			   {
                  if (gp_cohvec[j] == 0)    /*zero coherence*/
			         corrnumpercond = numLeftTrialperZeroCond;
			      else         /*non-zero coherence*/
			         corrnumpercond = numLeftTrialperCond;
			   }
               else                  /*Right*/
			   {
                  if (gp_cohvec[j] == 0)    /*zero coherence*/
			         corrnumpercond = numRightTrialperZeroCond;
			      else         /*non-zero coherence*/
			         corrnumpercond = numRightTrialperCond;
			   }
			   
	           if (numValidTrials[indx]<corrnumpercond)
	           {
	               for (k=0; k<corrnumpercond-numValidTrials[indx]; k++)
	               {
  		               unpickedArr[totalNums+totNum[i]] = indx;
		               totNum[i] ++;
	               }
			   }
			}
			totalNums = totalNums + totNum[i];
	}

    pickedTrialinBlock = unpickedArr[rand() % totalNums]; 
	
	if (pickedTrialinBlock <  NUM_DIRECTION * NUM_DIFF/2)    
        targetloc = 2;  /*Left*/
    else
	    targetloc = 1;  /*Right*/
    difficulty = pickedTrialinBlock % NUM_DIFF;
			 
    free(unpickedArr);
}


/*Set windows locations*/
int ctr_wnd()
{
	/* fixation window */
	wd_pos(WIND0, (long)fixPtX, (long)fixPtY);				
	wd_siz(WIND0, wd_fp_diam , wd_fp_diam);
	
	/* correct window */
	wd_pos(WIND1, Tx[0], Ty[0]);
	wd_siz(WIND1, wd_tg_diam, wd_tg_diam);
	
	/* distractor window */
	wd_pos(WIND2, Tx[1], Ty[1]);
	wd_siz(WIND2, wd_dist0_diam, wd_dist0_diam);
		
	/* target indicator window*/
	wd_pos(WIND3,Tx[0],Ty[0]);	
	wd_siz(WIND3, wd_indicator_diam, wd_indicator_diam);

	return(0);
}



long timept_now_fpoffset;   /* measure the time of fp off, ES 2015-11-15 */
long timept_now_reward;    /*measures the time of the correct trial. for fixed time to reward ES 27/7/16 */
int logi_timeReward;

long timept_now_cueonset;  /* measure the time of cue onset*/

long timept_now_targetholdon;
long timept_now_correct;
int logi_timepad_C;      

long timelength_past;      
long timelength_left;      

int measuretime_aroundcue(int chnstate)  
{
	switch (chnstate)
	{
	   case 0:   /* cue onset */
		{  
			timept_now_cueonset = getClockTime();
			return(0);   
		}
        case 1:       /*check whether urgency signal has passed (ready for reward) in reaction time task*/
		{  
			timept_now_reward = getClockTime();
			timelength_past = (timept_now_reward - timept_now_cueonset); 
			timelength_left = urgencysig - timelength_past;
			if (timelength_left <= 0)
			{  
     			logi_timeReward = 0;						
				return(0); 

			}
			else if (timelength_left > 0)
			{
				logi_timeReward = 1;   
			    return(0);   
			}
		}
	    case 2:        /* hold on target begins*/
	    {
			timept_now_targetholdon = getClockTime();
			return(0);   
	    }
        case 3:        /* check whether hold-on-target time reach the threshold for a correct trial*/
		{  
			timept_now_correct = getClockTime();
			timelength_past = (timept_now_correct - timept_now_targetholdon); 
			timelength_left = trange_sac2corr - timelength_past;
			if (timelength_left <= 0)
			{  
     			logi_timepad_C = 0;						
				return(0); 

			}
			else if (timelength_left > 0)
			{
				logi_timepad_C = 1;   
			    return(0);   
			}
		}
         
         /* case 6 for a measuring the time of fixation point offset. ES 15-11-2016 */       						  
         case 6: /* fp offset */
		{  
			timept_now_fpoffset = getClockTime();
			return(0);  
		}
		
        /* case 7 for a fixed time to reward. ES 27/7/16 */    
          case 7:     /*check whether it's time for reward after fp offset, in delayed task*/
		{  
			timept_now_reward = getClockTime();
			timelength_past = (timept_now_reward - timept_now_fpoffset); 
			timelength_left = time_to_reward - timelength_past;
			if (timelength_left <= 0)
			{  
     			logi_timeReward = 0;						
				return(0); 

			}
			else if (timelength_left > 0)
			{
				logi_timeReward = 1;   
			    return(0);   
			}
		}
	}
	
}


int rflag = 0;
long time_end = 0; 

float scalefactor = 0.8f;

/*-------------set the start time and end time of certain event ---------------*/
int fhf(int chnstate)
{
	long time_start;
	int a, fhf_min, fhf_max, Rtime;

	if (chnstate == 0)               /*time between target onset to cue onset*/
	{
		Rtime = fmean_delay;
        fhf_min =  ((double)Rtime) * (double)scalefactor ;
	    fhf_max =  ((double)Rtime) *((double)3.0 - 2.0* (double)scalefactor );  

 		a = fhf_max + 1;
	    if (logic_rand_cuePre == 1 )
	    {
	      while(a>fhf_max) 
		  { 
		    randnum();
		    randn = randn + .001f;
		    a = -1*Rtime*(log(randn)-log(1.0f));
		    a = ((((double)a)/((double)10000)) * ((double)(fhf_max - fhf_min))) + fhf_min;
	      }    
	    }
	    else if (logic_rand_cuePre == 0)
	    {
		   a = Rtime; 
	    }
	}
	else if (chnstate == 1)    /*keep fp on time in delayed task*/
	{
	    if (max_keepfpon_time < min_keepfpon_time)
		    max_keepfpon_time = min_keepfpon_time;
	    Rtime = min_keepfpon_time;
		a = Rtime + rand() % (max_keepfpon_time - min_keepfpon_time); 
	}
	 
	else if (chnstate == 2)    /*keep cue on time*/
	{
	    if (max_cueon_time < min_cueon_time)
		    max_cueon_time = min_cueon_time;
	    Rtime = min_cueon_time;
		a = Rtime + rand() % (max_cueon_time - min_cueon_time); 
	}
	
	time_start = getClockTime();

	time_end = time_start + a;

	return(0);
}


/*-----------check whether the current time past the end time of certain event ---------------*/
int timenow(void)
{
	rflag=0;
	
	long time_now=getClockTime();

	if (time_now < time_end)  
	   rflag=0;
	else 
	   rflag=1;
    return(0);
}


/*function used for independent reward value for each condition - ES and MA 10-28-2016*/
int rew_branch=0;
int reward_branching()
{
   /* MA ES */
   if (difficulty==0 && targetloc==1) /* Target location: 2 = left, 1 = right */
      rew_branch=1;
   if (difficulty == 1 && targetloc == 1)  
      rew_branch = 2;
	if (difficulty == 2 && targetloc == 1) 
      rew_branch = 3;     
	if (difficulty == 3 && targetloc == 1)
      rew_branch = 4;
	if (difficulty == 0 && targetloc == 2) 
      rew_branch = 5;
   if (difficulty == 1 && targetloc == 2) 
      rew_branch = 6;
	if (difficulty == 2 && targetloc == 2) 
      rew_branch = 7;     
	if (difficulty == 3 && targetloc == 2)
      rew_branch = 8;
}

/*check whether it reaches the end of a block in block design*/
int checkEndofBlock()
{
    int i, j; 
	int corrnumpercond;
				   
	for (i=0; i<NUM_DIRECTION*NUM_DIFF; i++)
	{
	    if ( i < NUM_DIRECTION*NUM_DIFF/2)   /*Left*/
		{
	      j = i % NUM_DIFF;
          if (gp_cohvec[j] == 0)    /*zero coherence*/
              corrnumpercond = numLeftTrialperZeroCond;
		  else         /*non-zero coherence*/
		      corrnumpercond = numLeftTrialperCond;
	    }
		else          /*Right*/
		{
	      j = i % NUM_DIFF;
          if (gp_cohvec[j] == 0)    /*zero coherence*/
              corrnumpercond = numRightTrialperZeroCond;
		  else         /*non-zero coherence*/
		      corrnumpercond = numRightTrialperCond;		
		}
	    if (numValidTrials[i] < corrnumpercond)
	       return (0);
	}

    return (1);
}

/*Print error trials*/
int ErrorDstor=0;
int printError(int flag)
{
    // error trials
	nError++;

	// total trials
	nTrial++;
		
	if (flag==5)
	{
		printf(ANSI_RED "\tChose distractor\n" ANSI_RESET);
		
		// valid trials
		vTrial++;
		
		// total valid trials for this stimulus direction 	
		lrvtrials[idxstimdir]++;
		
		ErrorDstor=ErrorDstor+1;

#ifdef PSYCHOMETRIC
		n_trials[difficulty][idxstimdir]++;
#endif

	}
	else if (flag==3)
	{ 
		printf(ANSI_YELLOW "\tAnticipatory saccade\n" ANSI_RESET); 
	}
	else if (flag==4)
	{ 
		printf(ANSI_YELLOW "\tFailed to make a saccade in time\n" ANSI_RESET); 
	}
	else if (flag==6)
	{ 
		printf(ANSI_YELLOW "\tFailed to acquire target\n" ANSI_RESET); 
	}
	else if (flag==7)
	{ 
		printf(ANSI_YELLOW "\tFailed to hold target\n" ANSI_RESET); 
	}
	else if (flag==8)
	{ 
		printf(ANSI_YELLOW "\tFailed to acquire target or distractor\n" ANSI_RESET); 
	}
	
	// overall statistics
	if(lrvtrials[0] > 0 && lrvtrials[1] > 0)
	{
		// right 
		float a = lrcorrectnum[0];
		float b = lrvtrials[0];
		// left
		float c = lrcorrectnum[1];
		float d = lrvtrials[1];
		// fraction of trials that are correct for each direction 
		printf("\t\tf(corr,L/R) = %3.1f, %3.1f\n",100.0*c/d,100.0*a/b);
	}

#ifdef PSYCHOMETRIC
		psychometric();
#endif

#ifdef HISTORY	
		// add data to the history buffer
		buf_coh[buf_cnt] = gp_cohvec[difficulty]; 
		buf_tgt[buf_cnt] = idxstimdir; 
		buf_err[buf_cnt] = 0; 
		buf_cnt++;
	
		printHistory();
#endif

	printf(ANSI_GREEN);
	printf("\t\tValid: %d, Total: %d\n",vTrial, nTrial);
	printf(ANSI_RESET);
	
	/* save the error flag of current trial, will be used to determine whether to repeat this error trial in the next trial*/
	respflag = -flag;

	/* determine errorlevel based on seriousness of error type */
	if ((respflag == -3) || (respflag == -4) || (respflag == -7))
	/* anticipatory saccade, saccade initiation failure, target hold failure */
	{
	   errorlevel = 1;
	}
	else if (respflag == -5)
	/* chose distractor */
	{
	   errorlevel = 2; 
	}
	else
	/* target acquisition failure, target or distractor acquisition failure */
	{
	  errorlevel = 0;
	}
	
	/* Block Design*/
	if (BLOCK_DESIGN == 1)
	{
 	    numValidTrials[pickedTrialinBlock]++;
	    if (checkEndofBlock()== 1)
		   newblock = 1;
		else
		   newblock = 0;
		
	}
	return(0);
}

/*Print invalid trials*/
int printInvalid(int flag)
{

	// total trials
	nTrial++;
	
	if (flag==1)
	{
		printf(ANSI_YELLOW "\tFailed to hold fixation\n" ANSI_RESET);
	}
	else if (flag==2)
	{
		printf(ANSI_YELLOW "\tFailed to acquire fixation\n" ANSI_RESET);
	}

	// overall statistics
	if(lrvtrials[0] > 0 && lrvtrials[1] > 0)
	{
		// right 
		float a = lrcorrectnum[0];
		float b = lrvtrials[0];
		// left
		float c = lrcorrectnum[1];
		float d = lrvtrials[1];
		// fraction of trials that are correct for each direction 
		printf("\t\tf(corr,L/R) = %3.1f, %3.1f\n",100.0*c/d,100.0*a/b);
	}

#ifdef PSYCHOMETRIC
	psychometric();
#endif

#ifdef HISTORY
	printHistory();
#endif

	printf(ANSI_GREEN);
	printf("\t\tValid: %d, Total: %d\n",vTrial, nTrial);
	printf(ANSI_RESET);

	respflag = -flag;
	return(0);
}


/*Print Correct Trials*/
int printSuccess()
{
 	int l=0;
	int r=0;

	// total valid trials
	vTrial++;

	// total trials
	nTrial++;
	

	// total valid trials for this stimulus direction 	
	lrvtrials[idxstimdir]++;

	// correct trials  for this stimulus direction 
	lrcorrectnum[idxstimdir]++;
	
	// overall statistics
	 if(lrvtrials[0] > 0 && lrvtrials[1] > 0)
	 {
		  // right 
		  float a = lrcorrectnum[0];
		  float b = lrvtrials[0];
		  // left
		  float c = lrcorrectnum[1];
		  float d = lrvtrials[1];
		  // fraction of trials that are correct for each direction 
		  printf("\t\tf(corr,L/R) = %3.1f, %3.1f\n",100.0*c/d,100.0*a/b);
	  }


	nCorrect++;                

	correctflag=1;
	respflag = correctflag;
	
#ifdef PSYCHOMETRIC
	n_trials[difficulty][idxstimdir]++;
	n_corr[difficulty][idxstimdir]++;
	psychometric();
#endif

	printf(ANSI_GREEN);
	printf("\t\tValid: %d, Total: %d\n",vTrial, nTrial);
	printf(ANSI_RESET);

#ifdef HISTORY	
	// add data to the history buffer
	buf_coh[buf_cnt] = gp_cohvec[difficulty]; 
	buf_tgt[buf_cnt] = idxstimdir; 
	buf_err[buf_cnt] = 1; 
	buf_cnt++;

	printHistory();
#endif

	/* Block Design*/
	if (BLOCK_DESIGN == 1)
	{
 	    numValidTrials[pickedTrialinBlock]++;
	    if (checkEndofBlock()== 1)
		   newblock = 1;
		else
		   newblock = 0;
		
	}

	return(0);
}


/*========================== psychometric function =============================*/

#ifdef PSYCHOMETRIC

// calculate the psychometric curve. Note: if gp_cohvec includes a coh=0 value, 
// the below definitions have the harmless effect of allocating one extra space */

int gp_cohvec_pos[NUM_DIFF]		= {0};
int gp_cohvec_neg[NUM_DIFF]		= {0};
float f_pos[NUM_DIFF]			= {0};
float f_0						=  0; 
float f_neg[NUM_DIFF]			= {0};

int psychometric()
{
	int i;
	int a, b, c, d;
	char jst[] = "\t\t";	// indent psychometric printout by this much
	char nan[] = "   . ";   // what to print when there's no data available
	char grt[] = "   > ";	// what to print when trial counts exceed a threshold

	//------------------------ there is a coh = 0 value ------------------------//
	
	if(gp_cohvec[NUM_DIFF-1] == 0)
	{
		// positive and negative coherence vectors given gp_cohvec
		for(i=0; i<NUM_DIFF-1; i++) gp_cohvec_neg[i] = -gp_cohvec[i];
		for(i=0; i<NUM_DIFF-1; i++)	gp_cohvec_pos[i] =  gp_cohvec[NUM_DIFF-2-i];

		// psychometric function f, for positive and negative coherences
		for(i=0; i<NUM_DIFF-1; i++) 
		{
			// stim right
			a = n_corr[i][0];											// saccade right 
			b = n_trials[i][0] - n_corr[i][0];							// saccade left

			// stim left
			c = n_trials[i][1] - n_corr[i][1];							// saccade right
			d = n_corr[i][1];											// saccade left

			// fraction of right saccades for stim left (negative) branch 
			if (c+d > 0) f_neg[i] = 100.0*c/(c+d);
			else f_neg[i] = -1; // no data

			// fraction of right saccades for stim right (positive) branch 
			if (a+b > 0) f_pos[NUM_DIFF-2-i] = 100.0*a/(a+b);
			else f_pos[NUM_DIFF-2-i] = -1;  // no data
		}
		
		// coh = 0 is a special case
		i = NUM_DIFF-1;
		a = n_corr[i][0];												// stim right, saccade right
		b = n_trials[i][0] - n_corr[i][0];								// stim right, saccade left
		c = n_trials[i][1] - n_corr[i][1];								// stim left,  saccade right
		d = n_corr[i][1];												// stim left,  saccade left
		if (a+b+c+d > 0) f_0 = 100.0*(a+c)/(a+b+c+d);					// fraction of right saccades
		else f_0 = -1; // no data 

		// print coherence values
		printf(ANSI_MAGENTA);
		printf("%sPsychometric:\n%s",jst,jst);
		for(i=0; i<NUM_DIFF-1; i++) 
			printf("%+4d ",gp_cohvec_neg[i]);							// negative
		printf("%+4d ",0);												// zero		
		for(i=0; i<NUM_DIFF-1; i++) 
			printf("%+4d ",gp_cohvec_pos[i]);							// positive
		printf("\n");

		// print the psychometric data
		printf("%s",jst);
		for(i=0; i<NUM_DIFF-1; i++)										// negative
		{
			if (f_neg[i] >= 0) 
				printf("%4.0f ",f_neg[i]);
			else 
				printf("%s",nan);
		}
		if (f_0 >= 0) 
			printf("%4.0f ",f_0);										// zero
		else 
			printf("%s",nan);
		for(i=0; i<NUM_DIFF-1; i++)										// positive
		{
			if (f_pos[i] >= 0) printf("%4.0f ",f_pos[i]);
			else printf("%s",nan);
		}
		printf("\n");
		printf(ANSI_RESET);

		// print the number of valid trials per coherence
		printf(ANSI_CYAN);
		printf("%s",jst);
			
		for(i=0; i<NUM_DIFF-1; i++)										// negative
		{
			if (n_trials[i][0] <= 999) 
				printf("%4d ",n_trials[i][1]);
			else 
				printf("  >  ");
		}

		i = NUM_DIFF-1;													// zero
		if (n_trials[i][0] + n_trials[i][1] <= 999) 
			printf("%4d ",n_trials[i][0] + n_trials[i][1]);


		for(i=0; i<NUM_DIFF-1; i++)										// positive 
		{
			if (n_trials[NUM_DIFF-2-i][1] <= 999) 
				printf("%4d ",n_trials[NUM_DIFF-2-i][0]);
			else 
				printf("  >  ");
		}
		
		printf(ANSI_RESET);
		printf("\n");

	}

	//------------------------ there is no coh = 0 value ------------------------//
	
	else
	{
		// positive and negative coherence vectors given gp_cohvec
		for(i=0; i<NUM_DIFF; i++) gp_cohvec_neg[i] = -gp_cohvec[i];
		for(i=0; i<NUM_DIFF; i++) gp_cohvec_pos[i] =  gp_cohvec[NUM_DIFF-1-i];

		// psychometric function f, for positive and negative coherences
		for(i=0; i<NUM_DIFF; i++) 
		{
			// stim right
			a = n_corr[i][0];										// saccade right 
			b = n_trials[i][0] - n_corr[i][0];						// saccade left

			// stim left
			c = n_trials[i][1] - n_corr[i][1];						// saccade right
			d = n_corr[i][1];										// saccade left

			// fraction of right saccades for stim left (negative) branch 
			if (c+d > 0) f_neg[i] = 100.0*c/(c+d);
			else f_neg[i] = -1; // no data

			// fraction of right saccades for stim right (positive) branch 
			if (a+b > 0) f_pos[NUM_DIFF-1-i] = 100.0*a/(a+b);
			else f_pos[NUM_DIFF-1-i] = -1;  // no data
		}

		// print coherence values
		printf(ANSI_MAGENTA);
		printf("%sPsychometric:\n%s",jst,jst);
		for(i=0; i<NUM_DIFF; i++) 
			printf("%+4d ",gp_cohvec_neg[i]);						// negative
		for(i=0; i<NUM_DIFF; i++) 
			printf("%+4d ",gp_cohvec_pos[i]);						// positive
		printf("\n");

		// print the psychometric data
		printf("%s",jst);
		for(i=0; i<NUM_DIFF; i++)									// negative
		{
			if (f_neg[i] >= 0) 
				printf("%4.0f ",f_neg[i]);
			else 
				printf("%s",nan);
		}
		for(i=0; i<NUM_DIFF; i++)									// positive
		{
			if (f_pos[i] >= 0) 
				printf("%4.0f ",f_pos[i]);
			else 
				printf("%s",nan);
		}
		printf("\n");
		printf(ANSI_RESET);

		// print the number of valid trials per coherence
		printf(ANSI_CYAN);
		printf("%s",jst);
			
		for(i=0; i<NUM_DIFF; i++)									// negative
		{
			if (n_trials[i][0] <= 999) 
				printf("%4d ",n_trials[i][1]);
			else 
				printf("%s",grt);
		}
		for(i=0; i<NUM_DIFF; i++)									// positive
		{
			if (n_trials[NUM_DIFF-1-i][1] <= 999) 
				printf("%4d ",n_trials[NUM_DIFF-1-i][0]);
			else 
				printf("%s",grt);
		}
		
		printf(ANSI_RESET);
		printf("\n");
	}
	return 0;
}

#endif
		

//---------------------------------------------------------------------------//
#ifdef HISTORY
int printHistory()
{
    int i;
	// print the history buffer
	if(buf_cnt >= buf_wdw)
	{
		printf("\t\tHistory:\n\t\t");
		for(i=buf_cnt-buf_wdw; i<buf_cnt; i++) printf("%4d ",buf_coh[i]);
		printf("\n\t\t");
		for(i=buf_cnt-buf_wdw; i<buf_cnt; i++) printf("%4c ",buf_tgt[i] == 0 ? 'R' : 'L');
		printf("\n\t\t");
		for(i=buf_cnt-buf_wdw; i<buf_cnt; i++) printf("%4c ",buf_err[i] == 0 ? 'E' : 'C');
		printf("\n");
	}
	else
	{
		printf("\t\tHistory:\n\t\t");
		for(i=0; i < buf_wdw-buf_cnt; i++) printf("%4c ",'.');
		for(i=0; i < buf_cnt; i++) printf("%4d ",buf_coh[i]);
		printf("\n\t\t");
		for(i=0; i < buf_wdw-buf_cnt; i++) printf("%4c ",'.');
		for(i=0; i < buf_cnt; i++) printf("%4c ",buf_tgt[i] == 0 ? 'R' : 'L');
		printf("\n\t\t");
		for(i=0; i < buf_wdw-buf_cnt; i++) printf("%4c ",'.');
		for(i=0; i < buf_cnt; i++) printf("%4c ",buf_err[i] == 0 ? 'E' : 'C');
		printf("\n");
	}
}
#endif

/*==============================================================================*/

int setdetect()
{
	sd_set(1);            /*Turn on Rex built-in saccade deterctor*/
	return(0);
}

/*Initialization function, being called when clock is turned on, or everytime when the Reset button is pressed*/
void rinitf(void)
{
	char *vexHost = "144.92.205.103";               /*Rig 3, IP of vex machine*/
	
	/*char *vexHost = "144.92.205.103";      */     /*Rig 1, IP of vex machine*/
	
	pcsConnectVex(vexHost);	/* establish socket connection to vex machine */	

	/*set the eye window postion and signal source*/
	
	wd_src_pos(WIND0, WD_DIRPOS, 0, WD_DIRPOS, 0);
	wd_src_pos(WIND1, WD_DIRPOS, 0, WD_DIRPOS, 0);
	wd_src_pos(WIND2, WD_DIRPOS, 0, WD_DIRPOS, 0);
	wd_src_check(WIND0, WD_SIGNAL, 0, WD_SIGNAL, 1);
	wd_src_check(WIND1, WD_SIGNAL, 0, WD_SIGNAL, 1);
	wd_src_check(WIND2, WD_SIGNAL, 0, WD_SIGNAL, 1);
	wd_cntrl(WIND0, WD_ON);
	wd_cntrl(WIND1, WD_ON);
	wd_cntrl(WIND2, WD_ON);

	wd_src_pos(WIND3, WD_DIRPOS, 0, WD_DIRPOS, 0);     
	wd_src_check(WIND3, WD_SIGNAL, 0, WD_SIGNAL, 1);
	wd_cntrl(WIND3, WD_ON);

	/*initialize random number generator*/
	srand((unsigned)time(0));

	if (BLOCK_DESIGN == 1)
	    newblock = 1;
	    	
	return(0);


}


/*Menu for display setup parameters*/
VLIST state_disp_vl[] = {
	"RF x coord", &rfx, NP, NP, 0, ME_DEC,
	"RF y coord", &rfy, NP, NP, 0, ME_DEC,
	
	"F.P. Cartesian: X", &fixPtX, NP, NP, 0, ME_FLOAT,
	"F.P. Cartesian: Y", &fixPtY, NP, NP, 0, ME_FLOAT,
	"F.P. size:", &fp_diam, NP, NP, 0, ME_DEC,
	"F.P. Clr(0:W,1:R,2:G,3:B,4:Blk)", &fpClrCD, NP, NP, 0, ME_DEC,
	"F.P. ClrRedLum(0-255)", &fpRedColor, NP, NP, 0, ME_DEC,
	"F.P. dim Clr", &fpdimClrCD, NP, NP, 0, ME_DEC,
	"F.P. Win rad 0.1 deg:", &wd_fp_diam, NP, NP, 0, ME_DEC,
	
	"Targ Win rad 0.1 deg:", &wd_tg_diam, NP, NP, 0, ME_DEC,
	"DIst Win rad 0.1 deg:", &wd_dist0_diam, NP, NP, 0, ME_DEC,
	"Target size", &tgsize,	NP,	NP,	0,	ME_DEC,
	"number of alternatives", &num_targ, NP, NP, 0, ME_DEC,
	"Alternative's Clr(1:white, 2:red)", &tgclrcd,  NP,  NP, 0, ME_DEC, 
	"Target Lum: 0-255 ", &tglum,  NP,  NP,  0,  ME_DEC,
	"Distractor Lum: 0-255 ", &distlum,  NP,  NP,  0,  ME_DEC,	
	NS,
};
char hm_sv_disp_vl[]= "";

/*Menu for experiment setup parameters*/
VLIST state_exp_vl[] = {	
	"Left bias (0-1)", &lbias, NP, NP, 0, ME_FLOAT,
	"repeat err trial(6:all types of errs, 0:off)",&repeatflag, NP,	NP,	0,	ME_DEC,
	
	"Task Type(1:ReactionTime, 2:Delay)", &tasktype, NP, NP, 0, ME_DEC,
	
	"Mean delay from ChoiceOn to CueOn", &fmean_delay, NP, NP, 0, ME_DEC,
	"Random the cue onset delay(1:on, 0:off)", &logic_rand_cuePre, NP, NP, 0, ME_DEC, 			
	"Min Cue on Time", &min_cueon_time, NP, NP, 0, ME_DEC,
	"Max Cue on Time", &max_cueon_time, NP, NP, 0, ME_DEC,
	"Time needed to hold on target for corr trial", &trange_sac2corr, NP, NP, 0, ME_LDEC,
	"Min Time to keep fp(from Cueoff to FPoff)", &min_keepfpon_time, NP, NP, 0, ME_DEC, 
    "Max Time to keep fp(from Cueoff to FPoff)", &max_keepfpon_time, NP, NP, 0, ME_DEC,
	"Fixed Time from FPOff to Reward",  &time_to_reward, NP, NP, 0, ME_LDEC,  /* ES the time from FP offset to reward*/	
	"Urgency signal(RT task:from Cueon to Rew)", &urgencysig, NP, NP, 0, ME_DEC, 
	
    "Block design flag (ON:1/OFF:0) ", &BLOCK_DESIGN, NP, NP, 0, ME_DEC,    
    "Num of shown(L+R) trials/nonzero coh per block", &numValidTrialperCond, NP, NP, 0, ME_DEC, 
    "Num of shown(L+R) trials/zero coh per block", &numValidTrialperZeroCond, NP, NP, 0, ME_DEC,   
	"Max trials in the session(0=infinite)", &maxvtrials, NP, NP, 0, ME_DEC,
	NS,
};
char hm_sv_exp_vl[]= "";

/*Menu for glass pattern parameters*/
VLIST glass_vl[] = {
	"nf1=120, num of frames with diff dot sets", &nf1, NP,	NP,	0, ME_DEC,
	"cycle1=10, num of repeation of nf1", &cycle1, NP,	NP,	0, ME_DEC,
	"nr1=6 deg height", &nr1, NP, NP, 0, ME_FLOAT,
	"nc1=6 deg width", &nc1, NP, NP, 0, ME_FLOAT,
	"ndots1=432/15", &ndots1, NP,	NP,	0, ME_DEC,
	"dotsize1=0.062 deg", &dotsize1, NP, NP, 0, ME_FLOAT,		
	"dwell1=1", &dwell1, NP,	NP,	0, ME_DEC,	
	"dt1=0; delta of frames", &dt1, NP,	NP,	0, ME_DEC,
	"dotamp1=1; dot lum", &dotamp1, NP, NP, 0, ME_FLOAT,	
	"dotbg1=0; background lum", &dotbg1, NP, NP, 0, ME_FLOAT,	
	"r1=0.4 deg", &r1, NP, NP, 0, ME_FLOAT,	
	"wander1=0", &wander1, NP, NP, 0, ME_FLOAT,		
	"framerate1=85 frames/sec", &framerate1, NP,	NP,	0, ME_DEC,
    "sw1=6 deg of mask diameter", &sw1, NP, NP, 0, ME_FLOAT,
	"sh1=0", &sh1, NP, NP, 0, ME_FLOAT,
	"sx1=0", &sx1, NP,	NP,	0, ME_DEC,	
	"sy1=0", &sy1, NP,	NP,	0, ME_DEC,
	"GP LocX-0.0, 50=5 deg/cm", &apt_xpos, NP, NP, 0, ME_FLOAT,
	"GP LocY-0.0, 50=5 deg/cm", &apt_ypos, NP, NP, 0, ME_FLOAT,
	"openGPorient=1 use orientSet as GP's", &openGPorient, NP,	NP,	0, ME_DEC,
	"orientSet=30 (0-180)", &orientSet, NP,	NP,	0, ME_DEC,
	"bg-gray,change bf ClockOn", &background, NP, NP, 0, ME_DEC,
	NS,
};

char hm_glass_vl[]= "";

/*Menu for eye signal setup*/
VLIST state_EyeCh_vl[] = {
 	"Eye Signals(0:(0,1) 1:(2,3))", &eyeSignal, NP, NP, 0, ME_DEC,
	NS,
};
char hm_state_EyeCh_vl[]="";


MENU umenus[] = {
	"Display params",  &state_disp_vl,	NP,	NP,	0,	NP,	hm_sv_disp_vl, 
	"Exp params",	&state_exp_vl,	NP,	NP,	0,	NP,	hm_sv_exp_vl, 
	"Glass pattern params", &glass_vl, NP, NP,	0,	NP,	hm_glass_vl, 
	"Eye Channel", &state_EyeCh_vl, NP, NP, 0, NP, hm_state_EyeCh_vl,
    NS,
};

%%
id 4444
restart rinitf
main_set{
status ON
begin
    first:
    	to befsecondcolor
	befsecondcolor:
		do backcolorset()
		to befsecond	
	befsecond:
		do PvexAllOff()
		to sebarloc on 0 % tst_rx_new
	sebarloc:
		do PvexStimLocation(&nobjBar, &objListBar, &locXBar, &locYBar)
		to setbar1 on 0 % tst_rx_new
	setbar1:
		do PvexSetStimColors(&nobjBar, &objListBar, &BarCovtag, &BarCovtag, &BarCovtag, &BarbackRed, &BarbackGreen, &BarbackBlue)
		to setbar2 on 0 % tst_rx_new
	setbar2:
		do PvexDrawBar(&nobjBar, &objListBar, &barorient, &barwidth, &barlength, &barcontrast)
		to barcmd on 0 % tst_rx_new
	barcmd:
		do PvexSwitchStim(&nobjBar, &objListBar, &fixOn) /*the Background bar on, not the FP*/
		to second on 0 % tst_rx_new	
    second:
        to enable on -PSTOP & softswitch
    enable:
        code ENABLECD 														/* Enable code */
        to setTG        
    setTG:
        do setTGLocation()
        to loadLoop   
    loadLoop:
        do initialize()
        to backlum
    backlum:
    	code &trialcode
        do PvexSetBackLum(&backRed, &backGreen, &backBlue)				/* Background luminance */
        to fploc on 0 % tst_rx_new
    fploc:
        do PvexSetFixLocation(&fixPtX, &fixPtY)							/* Set FP location	*/
        to fpclr on 0 % tst_rx_new
    fpclr:
        do PvexSetFixColors(&fpRed, &fpGreen, &fpBlue, &fpdimRed, &fpdimGreen, &fpdimBlue)
        to fpsiz on 0 % tst_rx_new     
    fpsiz:
        do PvexSetFixSiz(&fp_diam)	
        to stGlassStmPos on 0 % tst_rx_new  
    stGlassStmPos:                    /* Set the position of glass pattern*/
        do PvexStimLocation(&nGlassPattern, glassObjects, glassXLocs, glassYLocs)
		to gprecmode  on 0 % tst_rx_new                      
	gprecmode:
		do PvexGlassPatternRecMode(&nGlassPattern, glassObjects, &recGPMode, &nGPTrial);   /*set the GP recmode*/		
        to makeglasspattern1 on 0 % tst_rx_new  
    makeglasspattern1:               /* Make glass patterns, part one of the parameters */
        do PvexMakeGlassPatternOne(&nGlassPattern,glassObjects, glasspattype, glassframes, glassnr, glassnc, glassndots, glassdotsize, glassseed);
        to makeglasspattern2 on 0 % tst_rx_new
	makeglasspattern2:              /* Make glass patterns, part two of the parameters */
		do PvexMakeGlassPatternTwo(&nGlassPattern,glassObjects, glassdwell, glassdt, glassdotamp, glassdotbg, glasspercoh, glassang, glassr, glasswander);
        to maskglass on 0 % tst_rx_new
    maskglass:                      /* Mask glass patterns   */
        do PvexMaskGlass(&nGlassPattern, glassmaskObjects, glassmasksw, glassmasksh, glassmasksx, glassmasksy)
        to drwalter on 0 % tst_rx_new     
    drwalter:
        do PvexSetStimColors(&nObj, alterid, tgRed, tgGreen, tgBlue, bgBlack, bgBlack, bgBlack) /*foreground and background colors*/
        to alterlocation on 0 % tst_rx_new
    alterlocation:
        do PvexStimLocation(&nObj, alterid, Tx, Ty)
        to alteron on 0 % tst_rx_new
    alteron:
        do PvexDrawAnnulus(&nObj, alterid, outer, inner, cntrst)   /* This annulus is the 2 alternatives, use annulus to make them round patches!  */	
        to setwnd on 0 % tst_rx_new
    setwnd:
        do ctr_wnd()
        to openw      
    openw:
        do awind(OPEN_W)											/* begin collecting anaolg and event data */
        time 500
        to rstphoto11
    rstphoto11:
        do dio_off(PHOTO_RESET_BIT)
        time 10	
        to rstphoto12
    rstphoto12:
        code &oriencode                                             /* GP orientation code 10000+GPorient*/
        do dio_on(PHOTO_RESET_BIT)		
        to fpncmd
    fpncmd:
        do PvexSwitchFix(&fixOn)
        to fpon on +PHOTO_TRIG & photoTrigger
	fpon:
        code FPONCD 								    			/* FP on code */
        do setdetect()
        to zerow
    zerow:
        do set_wndcheck()
        to wfeye
    wfeye:
        time 500
        rand 500
        to fpholdtime on -WD0_XY & eyeflag
        to eaqfix												/* error in aquiring fixation point */
    fpholdtime:
        time 500
  		rand 200 
        to eaqfix on +WD0_XY & eyeflag						/* error in maintaining fixation */
        to eyein
    eyein:
        to eyein2 on -WD0_XY & eyeflag
        to eaqfix on +WD0_XY & eyeflag
    eyein2:
        code &tgecode											/* 4000 plus the target location  0 or 1 */
        to rstphoto21
    rstphoto21:
        do dio_off(PHOTO_RESET_BIT)
        time 10	
        to rstphoto22
    rstphoto22:
        do dio_on(PHOTO_RESET_BIT)
        to dropdfecode
    dropdfecode:
        code &dfecode
		to droprfxecode
	droprfxecode:
	    code &rfxecode
		to droprfyecode
	droprfyecode:
	    code &rfyecode
        to choicetgncmd
    choicetgncmd:
        do PvexSwitchStim(&nObj, alterid, TGOn)						/* turn on the choice targets */
        to tgtchoicecd on +PHOTO_TRIG & photoTrigger
    tgtchoicecd:												   /* DROP THE CHOICE TARGET ON CODE */
        code CHTGTONCD
        do fhf(0)                           /*target on, time check*/
        to cuedelay1
    cuedelay1:
        do timenow()
        to cuedelay2 on -WD0_XY & eyeflag
        to eaqfix on +WD0_XY & eyeflag
    cuedelay2:
        to showglassmovie on 1 = rflag  /* time_now >= time_end , turn the cue on*/
        to cuedelay1  
    showglassmovie:                 /* Show all the glass movies, glass patterns will be shown one by one, until time is up*/
        do PvexShowGlassMovieClip(&nGlassPattern,glassObjects,glassmovieframerate, glassmoviecycle)
        to movieStart on +PHOTO_TRIG & photoTrigger        
    movieStart:
        code CUEONCD
        to reactiontimetaskon on 1 = tasktype
        to delaytaskon on 2 = tasktype
/*------reaction time task---------*/
	reactiontimetaskon:
	    do measuretime_aroundcue(0) 
		to RTMinCueDura
    RTMinCueDura:
	   do fhf(2)                            /*cue on, time check*/
	   to RTcheckcuetime
	RTcheckcuetime:
	   do timenow()
	   to RTsacademade on +WD0_XY & eyeflag     /*saccade made in reaction time task*/
	   to RTcuekeepon
    RTcuekeepon:
        to esac on 1 = rflag  /* time_now >= time_end , fail to make a saccade in time */
        to RTcheckcuetime
	RTsacademade:
        code SACCD  
        to RTstoffcmd               
    RTstoffcmd:
       do PvexSwitchStim(&nGlassPattern, glassSwitchesex, offGlassSwitches)
       to RTdropcueoff on +PHOTO_TRIG & photoTrigger	
    RTdropcueoff:
	   code CUEOFFCD
	   to rstphoto71
    rstphoto71:
        do dio_off(PHOTO_RESET_BIT)
        time 10	
        to rstphoto72
    rstphoto72:
        do dio_on(PHOTO_RESET_BIT)   
	    to RTfpoffcmd12
    RTfpoffcmd12:  
	    do PvexSwitchFix(&fixOff) 
	    to RTrptfpoff12 on +PHOTO_TRIG & photoTrigger   /*0 % tst_rx_new*/
    RTrptfpoff12: 
        code FPOFFCD
        to RTpadpreCheckHold
    RTpadpreCheckHold:
        time 40  
        to RTpreCheckHold 		   
    RTpreCheckHold:  
        to RTchkhld_1 on -WD1_XY & eyeflag
        to eaqds on -WD2_XY & eyeflag
        to esac 
    RTchkhld_1:
    	do measuretime_aroundcue(2)
    	to RTchkhld       
    RTchkhld: 
		to RTholdtgdelay on -WD1_XY & eyeflag
        to ehldtg 
    RTholdtgdelay: 
    	do measuretime_aroundcue(3)	
    	to RTchkhld on 1 =  logi_timepad_C
        to RTchkbehavC  
    RTchkbehavC:
        to ehldtg on +WD1_XY & eyeflag 
        to RTCorrect on -WD1_XY & eyeflag 
    RTCorrect:
        code 5510 									/* Drop correct code for a correct response */
        do printSuccess()
    	to RTrewon_time1
    RTrewon_time1:
		to RTrewon_time
    RTrewon_time:
    	do measuretime_aroundcue(1)                 /*check urgency signal*/
      	to RTrewon_time1 on 1 =  logi_timeReward
      	to rewon_1                                  /*reward*/
/*------delayed task---------*/		
    delaytaskon:	
	    to DTMinCueDura
	DTMinCueDura:
	   do fhf(2)                                    /*cue on, time check*/
	   to DTcheckcuetime
	DTcheckcuetime:
	   do timenow()
	   to stoffeantsac on +WD0_XY & eyeflag      /*anticipatory saccade*/
	   to DTcuekeepon
    DTcuekeepon:
        to rstphoto41 on 1 = rflag  /* time_now >= time_end, turn the cue off */
        to DTcheckcuetime 
    stoffeantsac:
        do PvexSwitchStim(&nGlassPattern, glassSwitchesex, offGlassSwitches)
        to rpteantsac on +PHOTO_TRIG & photoTrigger 
    rpteantsac:
        code CUEOFFCD
        to fpoffcmd11     
    fpoffcmd11: 
        do PvexSwitchFix(&fixOff) 
	    to rptfpoff11  on 0 % tst_rx_new /*+PHOTO_TRIG & photoTrigger    */
    rptfpoff11:  
        code FPOFFCD         
        to eantsac        
    rstphoto41:
        do dio_off(PHOTO_RESET_BIT)
        time 10	
        to rstphoto42
    rstphoto42:
        do dio_on(PHOTO_RESET_BIT)		
        to stoffcmd               
    stoffcmd:
       do PvexSwitchStim(&nGlassPattern, glassSwitchesex, offGlassSwitches)
       to dropcueoff on +PHOTO_TRIG & photoTrigger	
    dropcueoff:
	   code CUEOFFCD
       to keepfp	
	keepfp:  /*added per lab conversation 11/09/2016 TC */
	   do fhf(1)                   /*cue offset, time check*/
	   to checkfptime
	checkfptime:
	   do timenow()
	   to fpoffcmd11 on +WD0_XY & eyeflag 
	   to fpkeepon
    fpkeepon:
        to rstphoto81 on 1 = rflag  /* time_now >= time_end , turn fp off*/
        to checkfptime 
    rstphoto81:
        do dio_off(PHOTO_RESET_BIT)
        time 10	
        to rstphoto82
    rstphoto82:
        do dio_on(PHOTO_RESET_BIT)		
        to fpoffcmd12  
    fpoffcmd12:  
	    do PvexSwitchFix(&fixOff) 
	    to rptfpoff12 on +PHOTO_TRIG & photoTrigger 
    rptfpoff12: 
        code FPOFFCD
        to measuretimefpoff 
    measuretimefpoff:	/* ES 2016-11-15 */
        do measuretime_aroundcue(6)     
		to prechkwnd  				
    prechkwnd:
        time 1000
        to rptsaccadecd on +WD0_XY & eyeflag
        to rptsaccadecd on -WD1_XY & eyeflag
        to rpteaqds on -WD2_XY & eyeflag
        to esac
    rpteaqds:
	    code SACCD
        to eaqds
    rptsaccadecd:   
        code SACCD  
        to DTpadpreCheckHold
    DTpadpreCheckHold:
        time 40  
        to preCheckHold 		   
    preCheckHold:  
        to chkhld_1 on -WD1_XY & eyeflag
        to eaqds on -WD2_XY & eyeflag
        to esac 
    chkhld_1:
    	do measuretime_aroundcue(2)
    	to chkhld       
    chkhld: /*check hold on target*/
		to holdtgdelay on -WD1_XY & eyeflag
        to ehldtg 
    holdtgdelay: 
    	do measuretime_aroundcue(3)	
    	to chkhld on 1 =  logi_timepad_C
        to chkbehavC  
    chkbehavC:
        to ehldtg on +WD1_XY & eyeflag 
        to DTcorrect on -WD1_XY & eyeflag 
    DTcorrect:
        code 5510 					/* Drop correct code for a correct response */
        do printSuccess()
    	to rewon_time1
    rewon_time1:
		to rewon_time
    rewon_time:
    	do measuretime_aroundcue(7)
      	to rewon_time1 on 1 =  logi_timeReward
      	to rewon_1
    rewon_1:
        do dio_on(REW)
        time 250 
        to rewoff_1
    rewoff_1:
        do dio_off(REW)	
        time 150	 
        to turnoff
    turnoff:
    	do PvexSwitchStim(&nObj, alterid, TGOff)   
        to rewardelay  on 0 % tst_rx_new 
    rewardelay: 
        code REWCD
        time 20 
		to closeawindC 
    eaqfix:
        code 5001 															/* Fail to acquire FP */
        do printInvalid(2)
        to erasefpFP
    erasefpFP:
        do PvexSwitchFix(&fixOff) 
        to erasefpTG on 0 % tst_rx_new
    erasefpTG:
        do PvexSwitchStim(&nObj, alterid, TGOff)           
        to bfclsawdcb_efix on 0 % tst_rx_new  /* +PHOTO_TRIG & photoTrigger    */	
    bfclsawdcb_efix:
	    time 200
		to closeawindEsoon
    closeawindEsoon:
        do awind(CLOSE_W)  
        time 200  
        to pscerebusC
    eantsac:
        code 5005 															/* anticipatory saccade */
        do printError(3)
        to emeasuretime  
    esac:
        code 5007 															/* violate saccade time limit */
        do printError(4)
        to emeasuretime
    eaqds:
        code 5006 															/* Incorrectly chose distractor */
        do printError(5) 
        to emeasuretime
    ehldtg:
        code 5004 															/* Fail to hold target */
        do printError(7)
        to emeasuretime
    emeasuretime:
    	to rstphoto61  
     rstphoto61:
        do dio_off(PHOTO_RESET_BIT)
        time 10	
        to rstphoto62
    rstphoto62:
        do dio_on(PHOTO_RESET_BIT)      
        to eraseAnnSt
    eraseAnnSt:
    	do PvexSwitchStim(&nGlassPattern, glassSwitchesex, offGlassSwitches)
    	to eraseAnnFP on 0 % tst_rx_new
    eraseAnnFP:
    	do PvexSwitchFix(&fixOff) 
    	to eraseAnnTG on 0 % tst_rx_new	
    eraseAnnTG:
    	do PvexSwitchStim(&nObj, alterid, TGOff) 
        to closeawindE on 0 % tst_rx_new 
    closeawindE:
        do awind(CLOSE_W)
        time 200
		to pscerebusE
    pscerebusE:
		code CBEVENT_PAUSEON
		to pauseonE on 2 = errorlevel
		to pauseonElight on 1 = errorlevel
    pauseonE:
        time 2000 /* 3000 */
        rand 100 /* 1000 */
        to laststate
    pauseonElight:
        time 1000
        rand 100
        to laststate
    closeawindC:
        do awind(CLOSE_W)
        time 200
		to pscerebusC
    pscerebusC:
	    code CBEVENT_PAUSEON
	    to pauseonC
    pauseonC:
        time 100	
        rand 100
        to laststate
    laststate:
        to second on 1 % trialgate
}

photoTrig {
status ON
begin	phfrst:
			to phdsbl
		phdsbl:
			to reset on -START & softswitch
		reset:
			do PsetFlag(&photoTrigger, 0)
			time 12   /*  2013-05-23, 1 to 12, following MA  */
			to rstpht
		rstpht:
			do dio_off(PHOTO_RESET_BIT)
			time 1    /*  2013-05-23, 1 to 10, following MA */
			to clrrst
		clrrst:
			do dio_on(PHOTO_RESET_BIT)
			to photo on +PHOTO_CELL_INPUT & drinput
		photo:
			do PsetFlag(&photoTrigger, 1)
			to phfrst
}

