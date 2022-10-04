import matlab.engine
import os
import pandas as pd

path = 'MovementObservation.csv'

def h5_to_csv():
    current_file = os.getcwd() + '\\' + '1week-Pair1DLC_dlcrnetms5_californiamouseMay31shuffle1_70000_el.h5'
    df = pd.read_hdf(current_file)
    df.dropna().to_csv(path)

def matlab_movement_analysis():
    eng = matlab.engine.start_matlab()
    eng.MiceMovementAnalysis(nargout=0)
    eng.quit()

if __name__ == '__main__':
    h5_to_csv()
    matlab_movement_analysis()