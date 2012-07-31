// Generates a large triangle wave

static int sigMax = 1023;
static int sigMin = 0;

float sigOut = 0.0;
float offset = 0.4;

int mod = 1;

void setup()
{
  Serial.begin(9600);
}

void loop()
{
  //int rand = random(1023);
  //sigOut = (rand - sigOut)*offset + sigOut;
  Serial.println(sigOut);
  sigOut+=mod;
  if(sigOut>sigMax || sigOut < sigMin)
    mod = mod*-1;
}
