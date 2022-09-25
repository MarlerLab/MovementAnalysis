import matlab.engine as matlabengine
import pandas as pd

path = 'MovementObservation.csv'

def h5_to_csv():
    current_file = '1week-Pair1DLC_dlcrnetms5_californiamouseMay31shuffle1_70000_el.h5'
    df = pd.read_hdf(current_file)
    df.dropna().to_csv(path)

def matlab_movement_analysis():
    eng = matlabengine.start_matlab()
    eng.simple_script(nargout=0)
    eng.quit()

if __name__ == '__main__':
    h5_to_csv()
    # matlab_movement_analysis()