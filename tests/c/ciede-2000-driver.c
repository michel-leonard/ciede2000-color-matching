// Limited Use License – March 1, 2025

// This source code is provided for public use under the following conditions :
// It may be downloaded, compiled, and executed, including in publicly accessible environments.
// Modification is strictly prohibited without the express written permission of the author.

// © Michel Leonard 2025

#include <math.h>
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include <sys/time.h>

typedef struct {
	struct {
		uint64_t seed;
		uint64_t generate;
		double tolerance;
		const char *delimiter;
		const char *input_file;
		const char *output_file;
		int canonical; // The deviation between 0 and 1 (option --canonical) can be up to ±0.0003 in ΔE2000 results.
		int precision;
		int verbose;
		int help;
		char mode;
	} params;
	char buf_1[255];
	char buf_2[255];
	char format[127];
	FILE *in_fp;
	FILE *out_fp;
	int code;
} state;

typedef struct {
	double l1;
	double a1;
	double b1;
	double l2;
	double a2;
	double b2;
	double delta_e;
	double tolerance;
	enum { SIMPLE, CANONICAL } compliance;
	char * name;
} reference;

static const reference references[ ] = {
	{67.7, -115.6, 5.2, 67.7, -115.6, 5.2, 0.0, 0.0, CANONICAL, "Basic"},
	{15.0, -84.0, -15.5, 15.0, -84.0, -15.5, 0.0, 0.0, CANONICAL, "Basic"},
	{62.0, -69.4, -21.0, 62.0, -69.4, -21.0, 0.0, 0.0, CANONICAL, "Basic"},
	{56.0, -41.5, 49.8, 56.0, -41.5, 49.8, 0.0, 0.0, CANONICAL, "Basic"},
	{7.0, -33.1, 56.0, 7.0, -33.1, 56.0, 0.0, 0.0, CANONICAL, "Basic"},
	{31.0, -28.0, -39.0, 31.0, -28.0, -39.0, 0.0, 0.0, CANONICAL, "Basic"},
	{46.8, 15.0, -78.0, 46.8, 15.0, -78.0, 0.0, 0.0, CANONICAL, "Basic"},
	{37.0, 21.0, 103.0, 37.0, 21.0, 103.0, 0.0, 0.0, CANONICAL, "Basic"},
	{68.0, 31.0, -41.0, 68.0, 31.0, -41.0, 0.0, 0.0, CANONICAL, "Basic"},
	{22.3, 89.3, 115.0, 22.3, 89.3, 115.0, 0.0, 0.0, CANONICAL, "Basic"},
	{55.2, -121.6, -78.7, 55.2, -121.6, -78.7, 0.0, 0.0, SIMPLE, "Basic"},
	{15.6, -61.5, -97.0, 15.6, -61.5, -97.0, 0.0, 0.0, SIMPLE, "Basic"},
	{85.0, -50.0, 95.0, 85.0, -50.0, 95.0, 0.0, 0.0, SIMPLE, "Basic"},
	{35.2, -24.9, 54.0, 35.2, -24.9, 54.0, 0.0, 0.0, SIMPLE, "Basic"},
	{96.2, -14.0, 43.0, 96.2, -14.0, 43.0, 0.0, 0.0, SIMPLE, "Basic"},
	{55.0, -5.5, 46.0, 55.0, -5.5, 46.0, 0.0, 0.0, SIMPLE, "Basic"},
	{76.2, 4.1, -91.0, 76.2, 4.1, -91.0, 0.0, 0.0, SIMPLE, "Basic"},
	{14.0, 13.3, 115.0, 14.0, 13.3, 115.0, 0.0, 0.0, SIMPLE, "Basic"},
	{22.0, 31.0, -0.5, 22.0, 31.0, -0.5, 0.0, 0.0, SIMPLE, "Basic"},
	{70.0, 81.6, 117.6, 70.0, 81.6, 117.6, 0.0, 0.0, SIMPLE, "Basic"},
	{88.94, -4.04, 92.37, 88.407, -5.5, 92.607, 0.838587362283, 1E-12, SIMPLE, "Fogra"},
	{77.37, 25.76, 91.54, 76.705, 24.102, 89.738, 0.882676623984, 1E-12, SIMPLE, "Fogra"},
	{60.42, 52.69, -9.17, 59.948, 51.204, -10.635, 0.968472883217, 1E-12, SIMPLE, "Fogra"},
	{72.38, -23.8, 65.39, 71.168, -23.262, 64.211, 0.972221099508, 1E-12, SIMPLE, "Fogra"},
	{46.43, 71.27, 58.55, 45.507, 73.159, 59.843, 0.994414797098, 1E-12, SIMPLE, "Fogra"},
	{64.34, -4.61, 66.28, 64.026, -5.34, 62.986, 1.052100291137, 1E-12, SIMPLE, "Fogra"},
	{46.41, 26.53, 17.14, 45.703, 25.037, 17.397, 1.135814580904, 1E-12, SIMPLE, "Fogra"},
	{49.45, -65.93, 24.35, 48.486, -68.861, 25.493, 1.214698443951, 1E-12, SIMPLE, "Fogra"},
	{43.67, -14.81, -50.35, 42.494, -15.947, -50.296, 1.233126646153, 1E-12, SIMPLE, "Fogra"},
	{76.04, -27.46, 75.95, 76.111, -26.998, 70.914, 1.257075972172, 1E-12, SIMPLE, "Fogra"},
	{70.62, 24.82, 71.77, 69.247, 24.949, 74.34, 1.270193833737, 1E-12, SIMPLE, "Fogra"},
	{80.47, -24.56, -3.87, 78.642, -24.449, -3.959, 1.27412294755, 1E-12, SIMPLE, "Fogra"},
	{75.43, 28.45, -9.24, 73.754, 29.262, -9.935, 1.321845897346, 1E-12, SIMPLE, "Fogra"},
	{36.51, 52.85, -11.26, 35.287, 53.43, -13.257, 1.346854418212, 1E-12, SIMPLE, "Fogra"},
	{73.41, 25.29, 20.42, 71.59, 25.013, 20.268, 1.374033346423, 1E-12, SIMPLE, "Fogra"},
	{40.13, 17.91, -38.49, 38.708, 16.935, -38.668, 1.443179831567, 1E-12, SIMPLE, "Fogra"},
	{51.64, -46.86, -39.77, 50.224, -48.022, -40.685, 1.464835115004, 1E-12, SIMPLE, "Fogra"},
	{61.29, -40.43, 18.62, 59.55, -40.548, 18.647, 1.522039927539, 1E-12, SIMPLE, "Fogra"},
	{52.96, -51.61, -21.76, 51.473, -53.402, -22.137, 1.560378184466, 1E-12, SIMPLE, "Fogra"},
	{35.49, 61.14, -12.6, 34.936, 62.656, -16.42, 1.609499202161, 1E-12, SIMPLE, "Fogra"},
	{55.94, -14.96, 6.09, 54.218, -14.548, 6.561, 1.701150935015, 1E-12, SIMPLE, "Fogra"},
	{48.01, -15.87, 9.54, 46.5, -15.289, 10.577, 1.71873432782, 1E-12, SIMPLE, "Fogra"},
	{90.44, -4.21, 61.28, 89.382, -6.752, 60.887, 1.729264080776, 1E-12, SIMPLE, "Fogra"},
	{48.06, 75.29, -5.18, 46.364, 77.031, -6.091, 1.734898444903, 1E-12, SIMPLE, "Fogra"},
	{37.42, 55.26, -24.12, 35.447, 57.048, -24.964, 1.735295108084, 1E-12, SIMPLE, "Fogra"},
	{40.0, -8.63, -54.86, 40.335, -10.752, -58.627, 1.769684396456, 1E-12, SIMPLE, "Fogra"},
	{42.09, -45.43, -11.14, 42.172, -49.601, -13.987, 1.780654853904, 1E-12, SIMPLE, "Fogra"},
	{56.12, -34.9, -52.52, 54.969, -38.467, -51.78, 1.780796353999, 1E-12, SIMPLE, "Fogra"},
	{53.65, 17.0, 14.18, 52.556, 15.238, 14.541, 1.789516309725, 1E-12, SIMPLE, "Fogra"},
	{76.04, -19.68, 8.86, 73.818, -20.952, 8.756, 1.799565142934, 1E-12, SIMPLE, "Fogra"},
	{62.24, 11.37, -26.06, 60.43, 10.648, -26.766, 1.81976775729, 1E-12, SIMPLE, "Fogra"},
	{48.17, 72.08, 14.73, 46.414, 72.812, 13.43, 1.835356574041, 1E-12, SIMPLE, "Fogra"},
	{34.72, 54.79, -5.39, 32.777, 55.155, -7.478, 1.839111896611, 1E-12, SIMPLE, "Fogra"},
	{24.74, 21.12, -47.45, 22.514, 23.538, -50.257, 1.841600840671, 1E-12, SIMPLE, "Fogra"},
	{42.01, -21.53, -29.73, 41.573, -22.817, -34.424, 1.84738067627, 1E-12, SIMPLE, "Fogra"},
	{45.69, -61.51, -24.28, 44.214, -58.828, -25.712, 1.874100505162, 1E-12, SIMPLE, "Fogra"},
	{41.19, -27.41, -38.39, 39.547, -29.414, -36.806, 1.8910604435, 1E-12, SIMPLE, "Fogra"},
	{47.99, 69.33, 45.87, 46.342, 70.08, 48.51, 1.897026905718, 1E-12, SIMPLE, "Fogra"},
	{58.43, 49.19, 36.75, 56.449, 50.619, 36.306, 1.957519300772, 1E-12, SIMPLE, "Fogra"},
	{92.3, -2.85, 30.21, 91.404, -5.249, 31.662, 1.959838917966, 1E-12, SIMPLE, "Fogra"},
	{13.3, 8.89, 4.27, 10.371, 8.39, 3.39, 2.030392848623, 1E-12, SIMPLE, "Fogra"},
	{59.91, 5.85, 1.88, 58.002, 4.874, 2.069, 2.031065691921, 1E-12, SIMPLE, "Fogra"},
	{66.57, -24.03, -39.84, 64.112, -24.539, -39.047, 2.055309791805, 1E-12, SIMPLE, "Fogra"},
	{46.75, 0.02, -3.26, 44.625, -0.17, -2.899, 2.076786726261, 1E-12, SIMPLE, "Fogra"},
	{38.63, 10.3, -16.1, 37.317, 8.368, -15.806, 2.084520088668, 1E-12, SIMPLE, "Fogra"},
	{28.46, 3.51, 2.52, 25.628, 3.181, 3.0, 2.209876615724, 1E-12, SIMPLE, "Fogra"},
	{46.55, 7.66, -18.54, 44.513, 6.489, -18.349, 2.246909231061, 1E-12, SIMPLE, "Fogra"},
	{79.15, -12.57, -24.93, 76.32, -13.586, -23.371, 2.276073255, 1E-12, SIMPLE, "Fogra"},
	{15.37, -3.2, 6.36, 11.974, -2.543, 5.4, 2.437035031448, 1E-12, SIMPLE, "Fogra"},
	{69.76, 0.49, -4.89, 66.832, 0.851, -4.076, 2.476095050968, 1E-12, SIMPLE, "Fogra"},
	{12.18, -3.46, -6.2, 8.78, -3.933, -7.824, 2.491650787411, 1E-12, SIMPLE, "Fogra"},
	{88.07, 4.18, -9.67, 87.125, 2.373, -7.522, 2.571394629497, 1E-12, SIMPLE, "Fogra"},
	{43.8, -55.27, -0.04, 41.313, -57.464, -2.004, 2.581920797965, 1E-12, SIMPLE, "Fogra"},
	{44.79, 3.14, 1.87, 42.135, 2.763, 2.589, 2.601082827439, 1E-12, SIMPLE, "Fogra"},
	{91.12, 8.1, 0.63, 89.531, 6.056, 2.111, 2.6677626158, 1E-12, SIMPLE, "Fogra"},
	{37.56, 6.18, 2.28, 35.08, 4.865, 3.105, 2.68009666001, 1E-12, SIMPLE, "Fogra"},
	{63.39, 4.9, 61.56, 64.192, 0.806, 62.124, 2.726073754875, 1E-12, SIMPLE, "Fogra"},
	{90.04, 8.17, -7.16, 88.614, 8.304, -3.797, 2.727178847734, 1E-12, SIMPLE, "Fogra"},
	{18.84, -1.48, 0.17, 14.812, -1.264, 0.738, 2.76974437794, 1E-12, SIMPLE, "Fogra"},
	{67.02, 12.75, -21.25, 68.315, 11.918, -24.7, 2.884886800173, 1E-12, SIMPLE, "Fogra"},
	{44.73, -49.16, -7.95, 41.803, -51.652, -9.505, 2.895001671874, 1E-12, SIMPLE, "Fogra"},
	{23.26, -1.43, -1.68, 19.376, -1.683, -0.695, 2.90604680834, 1E-12, SIMPLE, "Fogra"},
	{20.08, 7.99, -22.2, 16.334, 6.994, -23.27, 2.925089857046, 1E-12, SIMPLE, "Fogra"},
	{69.91, -47.0, -2.13, 66.424, -47.05, -4.316, 3.048767140291, 1E-12, SIMPLE, "Fogra"},
	{19.01, 34.61, -62.55, 14.689, 37.198, -63.877, 3.062939630973, 1E-12, SIMPLE, "Fogra"},
	{16.0, 0.07, -0.33, 11.17, -0.148, 0.285, 3.207574353807, 1E-12, SIMPLE, "Fogra"},
	{13.16, -7.6, 0.86, 10.68, -8.391, -2.409, 3.272531904025, 1E-12, SIMPLE, "Fogra"},
	{46.94, 47.81, 58.46, 44.28, 51.48, 57.1, 3.310858994638, 1E-12, SIMPLE, "Fogra"},
	{59.39, -70.17, 54.93, 58.667, -66.068, 43.0, 3.480481460066, 1E-12, SIMPLE, "Fogra"},
	{47.17, 72.84, 22.18, 45.221, 74.337, 15.795, 3.518640875603, 1E-12, SIMPLE, "Fogra"},
	{88.87, 1.19, -5.84, 86.478, 0.087, -2.242, 3.692313565528, 1E-12, SIMPLE, "Fogra"},
	{20.32, 41.53, -59.18, 15.562, 39.853, -61.648, 3.708884577857, 1E-12, SIMPLE, "Fogra"},
	{17.58, 6.51, -31.11, 13.188, 12.057, -39.632, 3.748267018947, 1E-12, SIMPLE, "Fogra"},
	{47.77, 42.07, 62.18, 45.336, 45.285, 57.9, 3.830199256297, 1E-12, SIMPLE, "Fogra"},
	{91.38, -4.77, -5.47, 90.299, -6.536, -1.268, 4.340954140808, 1E-12, SIMPLE, "Fogra"},
	{45.48, 24.05, -35.08, 46.942, 23.21, -42.018, 4.447215041573, 1E-12, SIMPLE, "Fogra"},
	{45.33, -43.3, 9.16, 43.103, -48.009, 3.034, 4.542766886741, 1E-12, SIMPLE, "Fogra"},
	{91.02, -2.14, -10.88, 89.416, -4.478, -6.348, 4.614279155061, 1E-12, SIMPLE, "Fogra"},
	{59.34, -74.76, 21.59, 54.565, -72.943, 17.595, 4.662176423291, 1E-12, SIMPLE, "Fogra"},
	{54.01, -70.39, -9.94, 49.437, -69.183, -12.018, 4.672374660662, 1E-12, SIMPLE, "Fogra"},
	{56.39, 64.03, 74.38, 52.417, 67.523, 69.833, 4.758584963952, 1E-12, SIMPLE, "Fogra"},
	{10.84, 8.87, -2.84, 7.595, 8.73, -8.641, 4.793463265932, 1E-12, SIMPLE, "Fogra"},
	{22.0, 47.0, -56.0, 16.862, 41.966, -58.784, 4.859485681741, 1E-12, SIMPLE, "Fogra"},
	{17.62, 3.28, 14.75, 15.336, 6.075, 11.016, 4.983711434622, 1E-12, SIMPLE, "Fogra"},
	{94.32, 0.15, 3.04, 93.521, -2.365, 8.108, 5.16396606892, 1E-12, SIMPLE, "Fogra"},
	{19.71, 30.16, -45.67, 15.035, 40.328, -58.507, 5.184802614594, 1E-12, SIMPLE, "Fogra"},
	{19.47, 42.71, -24.6, 18.406, 42.983, -36.008, 5.301639993207, 1E-12, SIMPLE, "Fogra"},
	{20.58, 44.92, -44.26, 15.076, 44.922, -54.017, 5.692787002868, 1E-12, SIMPLE, "Fogra"},
	{79.8, 28.24, 22.43, 76.73, 26.33, 13.503, 5.738109037289, 1E-12, SIMPLE, "Fogra"},
	{60.0, -75.0, 0.0, 54.209, -67.419, -2.476, 5.75091064044, 1E-12, SIMPLE, "Fogra"},
	{17.04, 32.75, -39.36, 11.798, 39.554, -52.579, 5.807428817617, 1E-12, SIMPLE, "Fogra"},
	{50.77, 38.67, 64.76, 46.995, 45.516, 60.764, 5.957939080686, 1E-12, SIMPLE, "Fogra"},
	{65.62, 56.35, 91.65, 60.604, 57.869, 79.662, 6.056549956286, 1E-12, SIMPLE, "Fogra"},
	{66.72, 53.65, 96.17, 62.426, 55.806, 82.301, 6.112447782974, 1E-12, SIMPLE, "Fogra"},
	{95.0, 1.5, -6.0, 94.316, -0.693, 0.169, 6.186404846623, 1E-12, SIMPLE, "Fogra"},
	{49.91, 40.11, 59.0, 44.955, 46.54, 56.226, 6.322287984208, 1E-12, SIMPLE, "Fogra"},
	{21.89, 33.94, 18.52, 18.339, 29.472, 8.445, 6.457340189792, 1E-12, SIMPLE, "Fogra"},
	{65.0, 58.0, 88.0, 58.406, 60.286, 77.341, 7.114761660003, 1E-12, SIMPLE, "Fogra"},
	{25.48, 25.53, 10.88, 19.91, 20.494, 1.48, 7.544971614715, 1E-12, SIMPLE, "Fogra"},
	{22.8, 35.25, -31.05, 17.448, 38.843, -46.888, 7.699808982696, 1E-12, SIMPLE, "Fogra"},
	{70.52, 46.43, 50.18, 65.191, 46.721, 35.493, 8.265211797222, 1E-12, SIMPLE, "Fogra"},
	{21.18, 37.73, -25.87, 16.668, 42.731, -45.182, 8.64178625956, 1E-12, SIMPLE, "Fogra"},
	{29.92, 0.37, 32.36, 22.974, 5.538, 21.722, 8.814934502704, 1E-12, SIMPLE, "Fogra"},
	{26.6, 2.02, 13.69, 20.564, 7.77, 10.179, 9.029636550064, 1E-12, SIMPLE, "Fogra"},
	{6.7747, -0.2908, -2.4247, 5.8714, -0.0985, -2.2286, 0.6377, 1E-4, CANONICAL, "Gaurav Sharma"},
	{2.0776, 0.0795, -1.135, 0.9033, -0.0636, -0.5514, 0.9082, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, -1.3802, -84.2814, 50.0, 0.0, -82.7485, 1.0, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, -1.1848, -84.8006, 50.0, 0.0, -82.7485, 1.0, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, -0.9009, -85.5211, 50.0, 0.0, -82.7485, 1.0, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.5, 0.0, 50.0, 1.8634, 0.5757, 1.0, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.5, 0.0, 50.0, 3.2592, 0.335, 1.0, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.5, 0.0, 50.0, 3.2972, 0.0, 1.0, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.5, 0.0, 50.0, 3.1736, 0.5854, 1.0, 1E-4, CANONICAL, "Gaurav Sharma"},
	{63.0109, -31.0961, -5.8663, 62.8187, -29.7946, -4.0864, 1.263, 1E-4, CANONICAL, "Gaurav Sharma"},
	{60.2574, -34.0099, 36.2677, 60.4626, -34.1751, 39.4387, 1.2644, 1E-4, CANONICAL, "Gaurav Sharma"},
	{36.4612, 47.858, 18.3852, 36.2715, 50.5065, 21.2231, 1.4146, 1E-4, CANONICAL, "Gaurav Sharma"},
	{90.8027, -2.0831, 1.441, 91.1528, -1.6435, 0.0447, 1.4441, 1E-4, CANONICAL, "Gaurav Sharma"},
	{90.9257, -0.5406, -0.9208, 88.6381, -0.8985, -0.7239, 1.5381, 1E-4, CANONICAL, "Gaurav Sharma"},
	{35.0831, -44.1164, 3.7933, 35.0232, -40.0716, 1.5901, 1.8645, 1E-4, CANONICAL, "Gaurav Sharma"},
	{61.2901, 3.7196, -5.3901, 61.4292, 2.248, -4.962, 1.8731, 1E-4, CANONICAL, "Gaurav Sharma"},
	{22.7233, 20.0904, -46.694, 23.0331, 14.973, -42.5619, 2.0373, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.6772, -79.7751, 50.0, 0.0, -82.7485, 2.0425, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, -1.0, 2.0, 50.0, 0.0, 0.0, 2.3669, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 0.0, 0.0, 50.0, -1.0, 2.0, 2.3669, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 3.1571, -77.2803, 50.0, 0.0, -82.7485, 2.8615, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.8361, -74.02, 50.0, 0.0, -82.7485, 3.4412, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.5, 0.0, 50.0, 0.0, -2.5, 4.3065, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, -0.001, 2.49, 50.0, 0.0011, -2.49, 4.7461, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, -0.001, 2.49, 50.0, 0.0009, -2.49, 4.8045, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, -0.001, 2.49, 50.0, 0.001, -2.49, 4.8045, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.49, -0.001, 50.0, -2.49, 0.0009, 7.1792, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.49, -0.001, 50.0, -2.49, 0.001, 7.1792, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.49, -0.001, 50.0, -2.49, 0.0011, 7.2195, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.49, -0.001, 50.0, -2.49, 0.0012, 7.2195, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.5, 0.0, 58.0, 24.0, 15.0, 19.4535, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.5, 0.0, 61.0, -5.0, 29.0, 22.8977, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.5, 0.0, 73.0, 25.0, -18.0, 27.1492, 1E-4, CANONICAL, "Gaurav Sharma"},
	{50.0, 2.5, 0.0, 56.0, -27.0, -3.0, 31.903, 1E-4, CANONICAL, "Gaurav Sharma"},
	{15.29, 0.29, 1.34, 15.29, 0.29, 1.34, 0.0, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{88.99, -4.02, 93.04, 89.0, -4.0, 93.0, 0.01, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{27.0, -0.01, 0.0, 27.0, 0.0, 0.0, 0.01, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{94.99, 1.01, -4.0, 95.0, 1.0, -4.0, 0.02, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{55.97, -37.06, -50.04, 56.0, -37.0, -50.0, 0.03, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{47.97, 75.06, -4.03, 48.0, 75.0, -4.0, 0.03, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{16.02, -0.02, -0.03, 16.0, 0.0, 0.0, 0.04, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{22.94, 0.02, 0.02, 23.0, 0.0, 0.0, 0.06, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{24.97, 20.04, -46.15, 25.0, 20.0, -46.0, 0.06, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{47.03, 67.94, 48.08, 47.0, 68.0, 48.0, 0.06, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{50.07, -65.99, 26.0, 50.0, -66.0, 26.0, 0.07, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{9.03, 0.21, 0.49, 9.05, .2, .39, 0.1, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{47.96, 71.05, -4.03, 48.0, 75.0, -4.0, 0.92, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{48.01, 64.97, 45.1, 47.0, 68.0, 48.0, 1.37, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{24.95, .02, .02, 23.0, 0.0, 0.0, 1.41, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{9.16, .07, 1.95, 9.05, .2, .39, 1.5, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{51.09, -61.98, 25.98, 50.0, -66.0, 26.0, 1.56, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{86.99, -4.02, 88.02, 89.0, -4.0, 93.0, 1.62, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{26.97, 17.06, -44.1, 25.0, 20.0, -46.0, 1.93, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{19.03, 0.0, .13, 16.0, 0.0, 0.0, 2.05, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{56.96, -37.06, -44.04, 56.0, -37.0, -50.0, 2.14, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{91.99, 0.01, 0.01, 95.00, 1.0, -4.0, 4.31, 1E-2, SIMPLE, "HutchColor Curve4 Guide"},
	{100.0, 0.0, 0.0, 100.0, 0.0, 0.0, 0.0, 1E-4, SIMPLE, "ICC HDR Working Group"},
	{84.25, 5.74, 96.0, 84.52, 5.75, 93.09, 0.5887, 1E-4, SIMPLE, "ICC HDR Working Group"},
	{84.25, 5.74, 96.0, 84.37, 5.86, 99.42, 0.6395, 1E-4, SIMPLE, "ICC HDR Working Group"},
	{84.25, 5.74, 96.0, 84.46, 8.88, 96.49, 1.6743, 1E-4, SIMPLE, "ICC HDR Working Group"},
	{50.0, 2.5, 0.0, 58.0, 24.0, 15.0, 19.4535, 1E-4, SIMPLE, "ICC HDR Working Group"},
	{50.0, 2.5, 0.0, 61.0, -5.0, 29.0, 22.8977, 1E-4, SIMPLE, "ICC HDR Working Group"},
	{50.0, 2.5, 0.0, 73.0, 25.0, -18.0, 27.1492, 1E-4, SIMPLE, "ICC HDR Working Group"},
	{50.0, 2.5, 0.0, 56.0, -27.0, -3.0, 31.903, 1E-4, SIMPLE, "ICC HDR Working Group"},
	{100.0, 0.0, 0.0, 0.0, 0.0, 0.0, 100.0, 1E-4, SIMPLE, "ICC HDR Working Group"},
	{50.0, +0.0, +0.0, 60.0, +0.0, +0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros ++_++)"},
	{50.0, +0.0, +0.0, 60.0, +0.0, -0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros ++_+-)"},
	{50.0, +0.0, +0.0, 60.0, -0.0, +0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros ++_-+)"},
	{50.0, +0.0, +0.0, 60.0, -0.0, -0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros ++_--)"},
	{50.0, +0.0, -0.0, 60.0, +0.0, +0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros +-_++)"},
	{50.0, +0.0, -0.0, 60.0, +0.0, -0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros +-_+-)"},
	{50.0, +0.0, -0.0, 60.0, -0.0, +0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros +-_-+)"},
	{50.0, +0.0, -0.0, 60.0, -0.0, -0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros +-_--)"},
	{50.0, -0.0, +0.0, 60.0, +0.0, +0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros -+_++)"},
	{50.0, -0.0, +0.0, 60.0, +0.0, -0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros -+_+-)"},
	{50.0, -0.0, +0.0, 60.0, -0.0, +0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros -+_-+)"},
	{50.0, -0.0, +0.0, 60.0, -0.0, -0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros -+_--)"},
	{50.0, -0.0, -0.0, 60.0, +0.0, +0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros --_++)"},
	{50.0, -0.0, -0.0, 60.0, +0.0, -0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros --_+-)"},
	{50.0, -0.0, -0.0, 60.0, -0.0, +0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros --_-+)"},
	{50.0, -0.0, -0.0, 60.0, -0.0, -0.0, 9.470578563636416377, 1E-12, SIMPLE, "M. Leonard (atan2 zeros --_--)"},
	{95.3, 58.8, 2.1, 95.7, 61.9, -1.7, 1.94085227194482418169, 1E-13, CANONICAL, "M. Leonard"},
	{88.3, 126.1, -1.7, 89.3, 109.1, 4.6, 3.39371063486055197872, 1E-13, CANONICAL, "M. Leonard"},
	{79.5, 66.7, 4.6, 76.1, 81.8, -5.0, 5.74362718998262151852, 1E-13, CANONICAL, "M. Leonard"},
	{20.5, 119.1, 8.1, 19.4, 96.5, -6.4, 6.04827511168188518218, 1E-13, CANONICAL, "M. Leonard"},
	{2.2, 97.5, -8.4, 7.0, 73.3, 10.5, 9.21336211899050078583, 1E-13, CANONICAL, "M. Leonard"},
	{29.6, 72.9, 7.1, 33.3, 113.4, -5.1, 9.46197920026345139417, 1E-13, CANONICAL, "M. Leonard"},
	{87.5, 94.2, -12.5, 85.5, 71.4, 14.8, 11.66863373476094834713, 1E-13, CANONICAL, "M. Leonard"},
	{49.3, 115.6, 15.8, 55.5, 68.6, -3.7, 12.66525563557193222345, 1E-13, CANONICAL, "M. Leonard"},
	{92.0, 83.5, -17.2, 94.0, 55.0, 12.5, 14.12388683336535160572, 1E-13, CANONICAL, "M. Leonard"},
	{75.4, 72.4, 14.1, 66.1, 42.7, -7.6, 14.6048483177113459227, 1E-13, CANONICAL, "M. Leonard"},
	{61.3, 65.6, 14.8, 73.3, 89.2, -18.8, 17.00889560002356621712, 1E-13, CANONICAL, "M. Leonard"},
	{76.6, 42.5, 18.7, 73.1, 25.0, -9.2, 17.25729977339333239023, 1E-13, CANONICAL, "M. Leonard"},
	{2.6, 47.0, -7.3, 5.8, 117.6, 19.6, 17.68717752672247225281, 1E-13, CANONICAL, "M. Leonard"},
	{34.3, 51.7, -16.4, 37.9, 95.8, 32.8, 21.34152170592487445292, 1E-13, CANONICAL, "M. Leonard"},
	{38.3, 112.8, -19.9, 28.7, 35.1, 6.4, 21.60551142778408239991, 1E-13, CANONICAL, "M. Leonard"},
	{58.4, 53.4, 17.4, 73.6, 84.8, -24.6, 22.45469609617014490807, 1E-13, CANONICAL, "M. Leonard"},
	{20.1, 23.4, -6.6, 12.8, 83.4, 31.1, 23.39420995517475573046, 1E-13, CANONICAL, "M. Leonard"},
	{44.5, 112.5, 44.0, 50.3, 28.9, -9.4, 26.98599512594377906629, 1E-13, CANONICAL, "M. Leonard"},
	{40.1, 15.7, 8.6, 49.8, 72.6, -34.6, 27.85378626098864902674, 1E-13, CANONICAL, "M. Leonard"},
	{89.0, 122.1, 53.2, 70.3, 90.0, -33.1, 29.8039267385598869929, 1E-13, CANONICAL, "M. Leonard"},
	{78.7, 65.2, -2.9, 77.5, 60.7, 2.8, 2.91989529567114087822, 1E-13, SIMPLE, "M. Leonard"},
	{76.8, 103.9, 6.6, 73.6, 116.1, -3.9, 4.57564890716434679028, 1E-13, SIMPLE, "M. Leonard"},
	{59.2, 71.8, 5.1, 58.6, 94.1, -4.7, 6.04596028354006873361, 1E-13, SIMPLE, "M. Leonard"},
	{86.3, 88.0, -4.8, 78.7, 118.6, 7.4, 8.43350328211329059147, 1E-13, SIMPLE, "M. Leonard"},
	{98.8, 71.4, 6.4, 93.9, 43.4, -3.3, 9.40747658309680880778, 1E-13, SIMPLE, "M. Leonard"},
	{43.8, 57.1, -5.2, 44.1, 91.2, 13.8, 10.71979501772133563859, 1E-13, SIMPLE, "M. Leonard"},
	{6.5, 54.8, -3.2, 14.5, 99.9, 6.0, 11.77900777893778130381, 1E-13, SIMPLE, "M. Leonard"},
	{93.9, 125.4, -7.6, 98.1, 60.4, 3.9, 13.3549692700726445113, 1E-13, SIMPLE, "M. Leonard"},
	{51.2, 48.7, 12.3, 47.1, 68.3, -15.2, 14.25583913083098798027, 1E-13, SIMPLE, "M. Leonard"},
	{73.9, 58.9, -10.7, 78.8, 99.1, 26.0, 16.46519883470241677672, 1E-13, SIMPLE, "M. Leonard"},
	{17.0, 103.1, 17.5, 6.2, 47.2, -7.2, 17.11285227600950336064, 1E-13, SIMPLE, "M. Leonard"},
	{47.7, 24.9, -10.5, 42.7, 38.4, 16.9, 17.46192736476249971483, 1E-13, SIMPLE, "M. Leonard"},
	{24.1, 31.9, 11.3, 26.1, 76.3, -17.3, 18.79784486369734963512, 1E-13, SIMPLE, "M. Leonard"},
	{11.8, 33.3, 9.9, 15.6, 98.7, -24.7, 21.40724135551181579439, 1E-13, SIMPLE, "M. Leonard"},
	{65.1, 119.6, 34.0, 52.8, 75.5, -20.6, 22.38225404176788836588, 1E-13, SIMPLE, "M. Leonard"},
	{31.0, 40.0, -10.5, 19.9, 95.1, 32.7, 22.68816897648419560562, 1E-13, SIMPLE, "M. Leonard"},
	{71.7, 117.3, -41.7, 67.4, 64.9, 23.1, 23.93214240881253107552, 1E-13, SIMPLE, "M. Leonard"},
	{37.2, 118.5, 36.4, 22.4, 32.1, -9.4, 27.16520888099369519862, 1E-13, SIMPLE, "M. Leonard"},
	{74.4, 33.6, 14.7, 89.2, 99.4, -43.2, 28.49937406290733230235, 1E-13, SIMPLE, "M. Leonard"},
	{34.6, 1.4, -12.5, 36.4, 13.8, 123.6, 43.19694490873158408704, 1E-13, SIMPLE, "M. Leonard"},
	{68.65, 27.21, 68.45, 68.63, 27.22, 68.3, 0.05, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 68.7, 26.97, 68.47, 0.15, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 69.51, 26.07, 65.15, 1.07, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 68.61, 25.02, 64.08, 1.19, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 67.87, 27.83, 64.92, 1.5, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 67.62, 29.67, 68.5, 1.6, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{89.88, -4.4, 94.8, 90.34, -7.51, 95.88, 1.62, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 69.42, 23.35, 63.29, 1.93, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{67.64, 29.07, 68.90, 68.48, 24.87, 63.84, 2.03, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 69.62, 22.92, 63.1, 2.17, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.1, 27.29, 72.29, 65.55, 26.74, 68.65, 2.26, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 66.8, 23.13, 64.97, 2.44, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{50.81, -62.6, 0.97, 52.94, -57.87, 0.29, 2.49, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 65.6, 25.28, 64.22, 2.68, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 69.56, 26.92, 58.23, 3.36, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 66.73, 31.73, 64.39, 3.85, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 66.8, 31.35, 63.38, 3.91, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 66.68, 31.94, 64.23, 4.01, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 70.72, 24.39, 55.11, 4.03, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 66.48, 31.77, 61.86, 4.63, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 66.48, 31.78, 61.89, 4.63, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 66.48, 31.79, 61.89, 4.64, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 66.59, 34.41, 65.1, 5.05, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 66.61, 34.67, 65.02, 5.2, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 66.49, 34.87, 65.46, 5.23, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 64.61, 32.98, 64.42, 5.31, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 64.57, 33.19, 63.75, 5.57, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"},
	{68.65, 27.21, 68.45, 68.64, 29.76, 52.2, 6.71, 1E-2, SIMPLE, "X-Rite eXact 2 + ColorCert QA"}
};

#define DeltaE(a, b, c) if (!strcmp(key, "--" #a) || !strcmp(key, "-" #b)) (c)
static int read_arg_2(const char **argv, state *state) {
	// Reads a key/value parameter received on the command line.
	const char *key = *argv, *value = *(argv + 1);
	DeltaE(delimiter, d, state->params.delimiter = value);
	else DeltaE(generate, g, state->params.generate = strtoull(value, 0, 10));
	else DeltaE(input-file, i, state->params.input_file = value);
	else DeltaE(output-file, o, state->params.output_file = value);
	else DeltaE(precision, p, state->params.precision = (int) strtol(value, 0, 10));
	else DeltaE(rand-seed, r, state->params.seed = strtol(value, 0, 10));
	else DeltaE(tolerance, t, state->params.tolerance = strtod(value, 0));
	else
		return 0;
	return 1;
}

static int read_arg_1(const char **argv, state *state) {
	// Reads a flag received on the command line.
	const char *key = *argv;
	DeltaE(canonical, c, state->params.canonical = 1);
	else DeltaE(help, h, state->params.help = 1);
	else DeltaE(solve, s, state->params.mode = 's');
	else DeltaE(verbose, v, state->params.verbose = 1);
	else
		return 0;
	return 1;
}
#undef DeltaE

static void open_descriptors(state *state) {
	if (state->params.input_file && state->params.output_file && !strcmp(state->params.input_file, state->params.output_file)) {
		fprintf(stderr, "Delta E 2000: Can't read and write the same file.\n");
		state->code = 3;
		return;
	}
	state->in_fp = stdin;
	state->out_fp = stdout;
	if (state->params.input_file) {
		state->in_fp = fopen(state->params.input_file, "rb");
		if (state->in_fp == 0) {
			perror("Delta E 2000");
			state->code = 3;
			return;
		}
	}
	if (state->params.output_file) {
		state->out_fp = fopen(state->params.output_file, "wb");
		if (state->out_fp == 0) {
			perror("Delta E 2000");
			state->code = 3;
			return;
		}
	}
}

static void close_descriptors(state *state) {
	if (state->in_fp != stdin)
		fclose(state->in_fp);
	if (state->out_fp != stdout)
		fclose(state->out_fp);
}

static inline uint64_t xor_random(uint64_t * restrict s) {
	// A shift-register generator has a reproducible behavior across platforms.
	return *s ^= *s << 13, *s ^= *s >> 7, *s ^= *s << 17;
}

static inline void perturb(double * restrict value, const double min, const double max, const uint32_t seed) {
	static const double magnitudes[16] = {
			-1e-12, +1e-12, -1.7e-11, +1.7e-11, -2.9e-10, +2.9e-10,
			-4.9e-9, +4.9e-9, -8.4e-8, +8.4e-8, -1.4e-6, +1.4e-6,
			-2.4e-5, +2.4e-5, -4.1e-4, +4.1e-4
	};
	if (!(seed & 31)) {
		*value += magnitudes[(seed >> 5) & 15] * (1.0 + ((seed >> 9) & 15));
		if (*value < min) *value = min; else if(max < *value) *value = max;
	} else if(*value == 0.0 && seed & 32)
		*value = -*value;
}

static inline void rand_lab(double * restrict l, double * restrict a, double * restrict b, uint64_t * restrict seed) {
	uint64_t x = xor_random(seed);
	const uint32_t y = x & 16383; x >>= 16;
	const uint32_t z = x & 32767; x >>= 16;
	const uint32_t t = x & 32767; x >>= 16;
	*l = x & 3 ? y % 101 : x & 4 ? y % 1000 / 10.0 : y % 10000 / 100.0;
	*a = x & 24 ? z % 257 - 128.0 : x & 32 ? (z % 2560 - 1280.0) / 10.0 : (z % 25600 - 12800.0) / 100.0;
	*b = x & 192 ? t % 257 - 128.0 : x & 256 ? (t % 2560 - 1280.0) / 10.0 : (t % 25600 - 12800.0) / 100.0;
	x = xor_random(seed);
	perturb(l, 0.0, 100.0, x & 32767); x >>= 16;
	perturb(a, -128.0, 128.0, x & 32767); x >>= 16;
	perturb(b, -128.0, 128.0, x & 32767);
}

// The functional CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
static double ciede_2000_functional(const double l1, const double a1, const double b1, const double l2, const double a2, const double b2, const int canonical) {
	// Working in C with the CIEDE2000 color-difference formula.
	// k_L, k_C, k_H are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_L = 1.0;
	const double k_C = 1.0;
	const double k_H = 1.0;

	const double pi_1 = 3.14159265358979323846;
	const double pi_3 = 1.04719755119659774615;

	// 1. Compute chroma magnitudes ... a and b usually range from -128 to +127
	const double a1_sq = a1 * a1;
	const double b1_sq = b1 * b1;
	const double c_orig_1 = sqrt(a1_sq + b1_sq);

	const double a2_sq = a2 * a2;
	const double b2_sq = b2 * b2;
	const double c_orig_2 = sqrt(a2_sq + b2_sq);

	// 2. Compute chroma mean and apply G compensation
	const double c_avg = 0.5 * (c_orig_1 + c_orig_2);
	const double c_avg_3 = c_avg * c_avg * c_avg;
	const double c_avg_7 = c_avg_3 * c_avg_3 * c_avg;
	const double g_denom = c_avg_7 + 6103515625.0;
	const double g_ratio = c_avg_7 / g_denom;
	const double g_sqrt = sqrt(g_ratio);
	const double g_factor = 1.0 + 0.5 * (1.0 - g_sqrt);

	// 3. Apply G correction to a components, compute corrected chroma
	const double a1_prime = a1 * g_factor;
	const double c1_prime_sq = a1_prime * a1_prime + b1 * b1;
	const double c1_prime = sqrt(c1_prime_sq);
	const double a2_prime = a2 * g_factor;
	const double c2_prime_sq = a2_prime * a2_prime + b2 * b2;
	const double c2_prime = sqrt(c2_prime_sq);

	// 4. Compute hue angles in radians, adjust for negatives and wrap
	const double safe_1 = 1e30 * (double)(b1 == 0.0 && a1_prime == 0.0);
	const double safe_2 = 1e30 * (double)(b2 == 0.0 && a2_prime == 0.0);
	// Compatibility: this can avoid NaN in atan2 when parameters are both zero
	const double h1_raw = atan2(b1, a1_prime + safe_1);
	const double h2_raw = atan2(b2, a2_prime + safe_2);
	const double h1_adj = h1_raw + (double) (h1_raw < 0.0) * 2.0 * pi_1;
	const double h2_adj = h2_raw + (double) (h2_raw < 0.0) * 2.0 * pi_1;
	const double delta_h = fabs(h1_adj - h2_adj);
	const double h_mean_raw = 0.5 * (h1_adj + h2_adj);
	const double h_diff_raw = 0.5 * (h2_adj - h1_adj);

	// Check if hue mean wraps around pi (180 deg)
	const double wrap_dist = fabs(pi_1 - delta_h);
	const double hue_wrap = (double) (1e-14 < wrap_dist && pi_1 < delta_h);

	double h_mean;
	if (canonical) {
		// Gaurav Sharma, OpenJDK, ...
		const double h_mean_hi = (double) (hue_wrap && h_mean_raw < pi_1) * pi_1;
		const double h_mean_lo = (double) (hue_wrap && h_mean_hi == 0.0) * pi_1;
		h_mean = h_mean_raw + h_mean_hi - h_mean_lo;
	} else
		// Bruce Lindbloom, Netflix’s VMAF, ...
		h_mean = h_mean_raw + hue_wrap * pi_1;

	// Michel Leonard 2025 - When mean wraps, difference wraps too
	const double h_diff = h_diff_raw + hue_wrap * pi_1;

	// 5. Compute hue rotation correction factor R_T
	const double c_bar = 0.5 * (c1_prime + c2_prime);
	const double c_bar_3 = c_bar * c_bar * c_bar;
	const double c_bar_7 = c_bar_3 * c_bar_3 * c_bar;
	const double rc_denom = c_bar_7 + 6103515625.0;
	const double R_C = sqrt(c_bar_7 / rc_denom);

	const double theta = 36.0 * h_mean - 55.0 * pi_1;
	const double theta_denom = -25.0 * pi_1 * pi_1;
	const double exp_argument = theta * theta / theta_denom;
	const double exp_term = exp(exp_argument);
	const double delta_theta = pi_3 * exp_term;
	const double sin_term = sin(delta_theta);

	// Rotation factor ... cross-effect between chroma and hue
	const double R_T = -2.0 * R_C * sin_term;

	// 6. Compute lightness term ... L nominally ranges from 0 to 100
	const double l_avg = 0.5 * (l1 + l2);
	const double l_delta_sq = (l_avg - 50.0) * (l_avg - 50.0);
	const double l_delta = l2 - l1;

	// Adaptation to the non-linearity of light perception ... S_L
	const double s_l_num = 0.015 * l_delta_sq;
	const double s_l_denom = sqrt(20.0 + l_delta_sq);
	const double S_L = 1.0 + s_l_num / s_l_denom;
	const double L_term = l_delta / (k_L * S_L);

	// 7. Compute chroma-related trig terms and factor T
	const double trig_1 = 0.17 * sin(h_mean + pi_3);
	const double trig_2 = 0.24 * sin(2.0 * h_mean + 0.5 * pi_1);
	const double trig_3 = 0.32 * sin(3.0 * h_mean + 1.6  * pi_3);
	const double trig_4 =  0.2 * sin(4.0 * h_mean + 0.15 * pi_1);
	const double T = 1.0 - trig_1 + trig_2 + trig_3 - trig_4;

	const double c_sum = c1_prime + c2_prime;
	const double c_product = c1_prime * c2_prime;
	const double c_geo_mean = sqrt(c_product);

	// 8. Compute hue difference and scaling factor S_H
	const double sin_h_diff = sin(h_diff);
	const double S_H = 1.0 + 0.0075 * c_sum * T;
	const double H_term = 2.0 * c_geo_mean * sin_h_diff / (k_H * S_H);

	// 9. Compute chroma difference and scaling factor S_C
	const double c_delta = c2_prime - c1_prime;
	const double S_C = 1.0 + 0.0225 * c_sum;
	const double C_term = c_delta / (k_C * S_C);

	// 10. Combine lightness, chroma, hue, and interaction terms
	const double L_part = L_term * L_term;
	const double C_part = C_term * C_term;
	const double H_part = H_term * H_term;
	const double interaction = C_term * H_term * R_T;
	const double delta_e_squared = L_part + C_part + H_part + interaction;
	const double delta_e_2000 = sqrt(delta_e_squared);

	return delta_e_2000;
}

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
static double ciede_2000_standard(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2, const int canonical) {
	// Working in C with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0;
	const double k_c = 1.0;
	const double k_h = 1.0;
	double n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// Application of the chroma correction factor.
	const double c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	const double c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n);
	double h_2 = atan2(b_2, a_2 * n);
	h_1 += (h_1 < 0.0) * 2.0 * M_PI;
	h_2 += (h_2 < 0.0) * 2.0 * M_PI;
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14)
		n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5;
	double h_d = (h_2 - h_1) * 0.5;
	h_d += (M_PI < n) * M_PI;
	if (canonical)
		// Gaurav Sharma, OpenJDK, ...
		h_m += (M_PI < n) * ((h_m < M_PI) - (M_PI <= h_m)) * M_PI;
	else
		// Bruce Lindbloom, Netflix’s VMAF, ...
		h_m += (M_PI < n) * M_PI;
	const double p = 36.0 * h_m - 55.0 * M_PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
			* sin(M_PI / 3.0 * exp(p * p / (-25.0 * M_PI * M_PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const double t = 1.0	+ 0.24 * sin(2.0 * h_m + M_PI / 2.0)
				+ 0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0)
				- 0.17 * sin(h_m + M_PI / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * M_PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that dE00 accurately reflects the
	// geometric distance in color space, which can range from 0 to around 185.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000-color-matching
//   Online Tests : https://michel-leonard.github.io/ciede2000-color-matching

// L1 = 71.2   a1 = 25.3   b1 = 2.8
// L2 = 71.3   a2 = 31.1   b2 = -2.6
// CIE ΔE00 = 4.2960204327 (Bruce Lindbloom, Netflix’s VMAF, ...)
// CIE ΔE00 = 4.2960051327 (Gaurav Sharma, OpenJDK, ...)
// Deviation between these two widely used variants ≈ 1.5e-5

static int ensure(const reference *r) {
	const double delta_e_1 = ciede_2000_standard(r->l1, r->a1, r->b1, r->l2, r->a2, r->b2, r->compliance == CANONICAL);
	const double delta_e_2 = ciede_2000_functional(r->l1, r->a1, r->b1, r->l2, r->a2, r->b2, r->compliance == CANONICAL);
	const int res = fabs(delta_e_1 - r->delta_e) <= r->tolerance && fabs(delta_e_2 - r->delta_e) <= r->tolerance;
	if (!res) {
		fprintf(stderr, "Test '%s' (%s compliance) failed :\n", r->name, r->compliance == CANONICAL ? "canonical" : "simple");
		fprintf(stderr, "  - ciede_2000(%g, %g, %g, %g, %g, %g) != %g\n", r->l1, r->a1, r->b1, r->l2, r->a2, r->b2, r->delta_e);
		fprintf(stderr, "  - got standard=%g, functional=%g\n", delta_e_1, delta_e_2);
	}
	return res;
}

static int static_controls(void) {
	int res = 1;
	for (int i = 0; i < sizeof(references) / sizeof(*references); ++i) {
		const reference *r_1 = references + i;
		reference r_2 = *r_1;
		r_2.l1 = r_1->l2, r_2.a1 = r_1->a2, r_2.b1 = r_1->b2;
		r_2.l2 = r_1->l1, r_2.a2 = r_1->a1, r_2.b2 = r_1->b1;
		res &= ensure(r_1);
		res &= ensure(&r_2);
	}
	return res;
}

static uint64_t get_time_ms(void) {
	// returns the current Unix timestamp with milliseconds.
	struct timeval time;
	gettimeofday(&time, 0);
	return (uint64_t) time.tv_sec * 1000 + (uint64_t) time.tv_usec / 1000;
}
#define Precision "%.15g"
#define DeltaE_default(a, b) ((a) <= 0 ? (b) : (a))
static void generate(state *state) {
	const uint64_t time_1 = get_time_ms();
	if (state->params.seed == 0)
		state->params.seed = time_1;
	uint64_t seed = state->params.seed ^ 0x2236b69a7d223bd;
	for (uint64_t i = 0, j = seed + (seed == 0); xor_random(&j), i < 64; ++i)
		seed ^= (j & 1) << i;
	const int number = (int)DeltaE_default(state->params.generate, 10);
	const char s = (char) (state->params.delimiter ? DeltaE_default(*state->params.delimiter, ',') : ',');
	sprintf(state->format, "%" Precision "%c%" Precision "%c%" Precision "%c%" Precision "%c%" Precision "%c%" Precision "\n", s, s, s, s, s);
	double l_1, a_1, b_1, l_2, a_2, b_2;
	for (int i = (sizeof(references) / sizeof(*references)) << 1; i < number; ++i) {
		rand_lab(&l_1, &a_1, &b_1, &seed);
		rand_lab(&l_2, &a_2, &b_2, &seed);
		fprintf(state->out_fp, state->format, l_1, a_1, b_1, l_2, a_2, b_2);
		const double delta_1 = ciede_2000_standard(l_1, a_1, b_1, l_2, a_2, b_2, state->params.canonical);
		const double delta_2 = ciede_2000_functional(l_2, a_2, b_2, l_1, a_1, b_1, state->params.canonical);
		assert(isfinite(delta_1) && isfinite(delta_2) && fabs(delta_1 - delta_2) < 1E-12);
		if (++i < number) {
			// Symmetry : the developed ciede_2000 functions must produce the same
			// result regardless of the order in which the two colors are provided.
			fprintf(state->out_fp, state->format, l_2, a_2, b_2, l_1, a_1, b_1);
		}
	}
	for (int i = 0; i < sizeof(references) / sizeof(*references); ++i) {
		const reference *r = references + i;
		fprintf(state->out_fp, "%.04f%c%.04f%c%.04f%c%.04f%c%.04f%c%.04f\n", r->l1, s, r->a1, s, r->b1, s, r->l2, s, r->a2, s, r->b2);
		fprintf(state->out_fp, "%.04f%c%.04f%c%.04f%c%.04f%c%.04f%c%.04f\n", r->l2, s, r->a2, s, r->b2, s, r->l1, s, r->a1, s, r->b1);
	}
	fprintf(stderr, "Generated %d test cases in %.2f s using seed %" PRIu64 ".\n", number, (double) (get_time_ms() - time_1) / 1000.0, state->params.seed);
}
#undef Precision

static void solve(state *state) {
	char s[2] = {0};
	const uint64_t time_1 = get_time_ms();
	const int p = state->params.precision, q = p < 1 || 15 < p ? 15 : p;
	s[0] = (char) (state->params.delimiter ? DeltaE_default(*state->params.delimiter, ',') : ',');
	sprintf(state->format, "%s%%.%df\n", s, q);
	while (fgets(state->buf_1, sizeof(state->buf_1) / sizeof(*state->buf_1) - 1, state->in_fp)) {
		char *pos = strrchr(state->buf_1, '\n');
		*(pos - (pos != state->buf_1 && *(pos - 1) == '\r')) = 0;
		fprintf(state->out_fp, "%s", state->buf_1);
		const char *t_1 = strtok(state->buf_1, s), *t_2 = strtok(0, s), *t_3 = strtok(0, s);
		const char *t_4 = strtok(0, s), *t_5 = strtok(0, s), *t_6 = strtok(0, "\r\n");
		if (t_1 && t_2 && t_3 && t_4 && t_5 && t_6) {
			const double l_1 = strtod(t_1, 0), a_1 = strtod(t_2, 0), b_1 = strtod(t_3, 0);
			const double l_2 = strtod(t_4, 0), a_2 = strtod(t_5, 0), b_2 = strtod(t_6, 0);
			if (isfinite(l_1) && isfinite(a_1) && isfinite(b_1) && isfinite(l_2) && isfinite(a_2) && isfinite(b_2)) {
				// Solving the ΔE2000 could also be done with the standard implementation, but is done with the functional implementation
				const double delta_e = ciede_2000_functional(l_1, a_1, b_1, l_2, a_2, b_2, state->params.canonical);
				fprintf(state->out_fp, state->format, delta_e);
			} else
				fputc('\n', state->out_fp);
		} else
			fputc('\n', state->out_fp);
	}
	if (state->params.verbose)
		fprintf(stderr, "Solved in %.2f s.\n", (double) (get_time_ms() - time_1) / 1000.0);
}

static void control(state *state) {
	char s[2] = {0};
	uint64_t time_1 = 0;
	const double t = state->params.tolerance, tolerance = t < 0.0 ? 0.0 : 10.0 < t ? 10.0 : t;
	s[0] = (char) (state->params.delimiter ? DeltaE_default(*state->params.delimiter, ',') : ',');
	int do_copy = 1, n_lines = 0, n_errors = 0, n_successes = 0, errors_displayed = 0, has_new_error;
	double max_error = 0.0, sum_errors = 0.0, sum_delta_e = 0.0;
	while (fgets(state->buf_1, sizeof(state->buf_1) / sizeof(*state->buf_1) - 1, state->in_fp)) {
		++n_lines;
		if (do_copy)
			strcpy(state->buf_2, state->buf_1);
		const char *t_1 = strtok(state->buf_1, s), *t_2 = strtok(0, s), *t_3 = strtok(0, s);
		const char *t_4 = strtok(0, s), *t_5 = strtok(0, s), *t_6 = strtok(0, s), *t_7 = strtok(0, "\r\n");
		if (t_1 && t_2 && t_3 && t_4 && t_5 && t_6 && t_7) {
			const double l_1 = strtod(t_1, 0), a_1 = strtod(t_2, 0), b_1 = strtod(t_3, 0);
			const double l_2 = strtod(t_4, 0), a_2 = strtod(t_5, 0), b_2 = strtod(t_6, 0);
			const double delta_e = strtod(t_7, 0);
			if (isfinite(l_1) && isfinite(a_1) && isfinite(b_1) && isfinite(l_2) && isfinite(a_2) && isfinite(b_2) && isfinite(delta_e)) {
				// Checking the ΔE2000 could also be done with the standard implementation, but is done with the functional implementation
				const double expected_delta_e = ciede_2000_functional(l_1, a_1, b_1, l_2, a_2, b_2, state->params.canonical);
				const double error = fabs(expected_delta_e - delta_e);
				sum_delta_e += expected_delta_e;
				sum_errors += error;
				has_new_error = max_error < error;
				if (has_new_error)
					max_error = error;
				if (tolerance < error) {
					++n_errors;
					if (has_new_error && ++errors_displayed <= 5) {
						fprintf(stderr, "Line %-4d : L1=%.17g a1=%.17g b1=%.17g\n", n_lines, l_1, a_1, b_1);
						fprintf(stderr, "            L2=%.17g a2=%.17g b2=%.17g\n", l_2, a_2, b_2);
						fprintf(stderr, "Expecting : %.17f       Found deviation : %.3g\n", expected_delta_e, error);
						fprintf(stderr, "      Got : %.17f\n\n", delta_e);
					}
				} else
					++n_successes;
				if (do_copy) {
					do_copy = 0;
					time_1 = get_time_ms();
				}
			}
		}
	}
	if (n_successes || n_errors) {
		fprintf(state->out_fp, "CIEDE2000 Verification Summary :\n");
		fprintf(state->out_fp, "  First Verified Line : %s", state->buf_2);
		fprintf(state->out_fp, "             Duration : %.02f s\n", (double) (get_time_ms() - time_1) / 1000.0);
		fprintf(state->out_fp, "            Successes : %d\n", n_successes);
		fprintf(state->out_fp, "               Errors : %d\n", n_errors);
		fprintf(state->out_fp, "      Average Delta E : %.4f\n", sum_delta_e / (n_successes + n_errors));
		fprintf(state->out_fp, "    Average Deviation : %.1e\n", sum_errors / (n_successes + n_errors));
		fprintf(state->out_fp, "    Maximum Deviation : %.1e\n\n", max_error);
	} else
		fprintf(stderr, "No data to verify.\n");
}
#undef DeltaE_default

static void print_help(void) {
	puts("           Name: Delta E 2000 Driver");
	puts("    Description: Generate, solve and control Color Difference");
	puts("");
	puts("     General options:");
	puts("       -d <char> or --delimiter to customize the field separator (default to comma)");
	puts("       -i <path> or --input-file to specify a file (default to stdin)");
	puts("       -o <path> or --outout-file to specify a file (default to stdout)");
	puts("       -c or --canonical to comply with the canonical definition of the hue mean");
	puts("");
	puts("     Options:");
	puts("       -g <count> or --generate to generate a dataset of Lab colors");
	puts("          -r <seed> or --rand-seed to customize the RNG seed");
	puts("       -s or --solve to solve a dataset by appending the Delta E 2000");
	puts("          -p <digits> or --precision to customize the display precision");
	puts("");
	puts("     By default, without -g or -s this driver checks the lines it reads on its standard input");
	puts("     and -t <number> (for --tolerance) can be used to adjust its tolerance (default to 1e-10)");
	puts("");
	puts(" GitHub Project: https://github.com/michel-leonard/ciede2000-color-matching");
	puts(" Release Date: March 1, 2025");
}

int main(int argc, const char *argv[]) {
	state state = {0};
	if (static_controls()) {
		state.params.tolerance = 1e-10;
		state.params.precision = 12;
		for (int i = 1; i < argc; ++i)
			if (!(i + 1 < argc && read_arg_2(argv + i, &state) && ++i))
				if (!read_arg_1(argv + i, &state))
					fprintf(stderr, "Delta E 2000: Unknown argument '%s'.\n", (state.code = 2, argv[i]));
		if (state.params.help)
			print_help();
		else if (state.code == 0) {
			open_descriptors(&state);
			if (state.code == 0) {
				if (state.params.generate)
					generate(&state);
				else if (state.params.mode == 's')
					solve(&state);
				else
					control(&state);
			}
			close_descriptors(&state);
		}
	} else
		state.code = 1;
	return state.code;
}

// Compilation is done with GCC or Clang :
// - gcc -std=c99 -Wall -pedantic -O2 -g -o driver ciede-2000-driver.c -lm
// - clang -std=c99 -Wall -pedantic -O2 -g -o driver ciede-2000-driver.c -lm
