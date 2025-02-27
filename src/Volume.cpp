//*****************************************************************
/*
  JackTrip: A System for High-Quality Audio Network Performance
  over the Internet

  Copyright (c) 2020 Julius Smith, Juan-Pablo Caceres, Chris Chafe.
  SoundWIRE group at CCRMA, Stanford University.

  Permission is hereby granted, free of charge, to any person
  obtaining a copy of this software and associated documentation
  files (the "Software"), to deal in the Software without
  restriction, including without limitation the rights to use,
  copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the
  Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  OTHER DEALINGS IN THE SOFTWARE.
*/
//*****************************************************************

/**
 * \file Volume.cpp
 * \author Matt Horton
 * \date September 2022
 * \license MIT
 */

#include "Volume.h"

#include <QVector>

#include "jacktrip_types.h"

//*******************************************************************************
void Volume::init(int samplingRate)
{
    ProcessPlugin::init(samplingRate);
    if (samplingRate != fSamplingFreq) {
        std::cerr << "Sampling rate not set by superclass!\n";
        std::exit(1);
    }
    fs = float(fSamplingFreq);

    for (int i = 0; i < mNumChannels; i++) {
        volumeP[i]->init(fs);  // compression filter parameters depend on sampling rate
        int ndx = volumeUIP[i]->getParamIndex("Volume");
        volumeUIP[i]->setParamValue(ndx, mVolMultiplier);
        ndx = volumeUIP[i]->getParamIndex("Mute");
        volumeUIP[i]->setParamValue(ndx, isMuted ? 1 : 0);
    }
    inited = true;
}

//*******************************************************************************
void Volume::compute(int nframes, float** inputs, float** outputs)
{
    if (not inited) {
        std::cerr << "*** Volume " << this << ": init never called! Doing it now.\n";
        if (fSamplingFreq <= 0) {
            fSamplingFreq = 48000;
            std::cout << "Volume " << this
                      << ": *** HAD TO GUESS the sampling rate (chose 48000 Hz) ***\n";
        }
        init(fSamplingFreq);
    }

    for (int i = 0; i < mNumChannels; i++) {
        /* Run the signal through Faust  */
        volumeP[i]->compute(nframes, &inputs[i], &outputs[i]);
    }
}

//*******************************************************************************
void Volume::updateNumChannels(int nChansIn, int nChansOut)
{
    if (outgoingPluginToNetwork) {
        mNumChannels = nChansIn;
    } else {
        mNumChannels = nChansOut;
    }
}

void Volume::volumeUpdated(float multiplier)
{
    // maps 0.0-1.0 to a -40 dB to 0 dB range
    // update if volumedsp.dsp and/or volumedsp.h
    // change their ranges
    mVolMultiplier = 40.0 * multiplier - 40.0;
    for (int i = 0; i < mNumChannels; i++) {
        int ndx = volumeUIP[i]->getParamIndex("Volume");
        volumeUIP[i]->setParamValue(ndx, mVolMultiplier);
    }
}

void Volume::muteUpdated(bool muted)
{
    isMuted = muted;
    for (int i = 0; i < mNumChannels; i++) {
        int ndx = volumeUIP[i]->getParamIndex("Mute");
        volumeUIP[i]->setParamValue(ndx, isMuted ? 1 : 0);
    }
}