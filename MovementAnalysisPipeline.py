import matlab.engine
import os
import pandas as pd

csv_path = 'MovementObservation.csv'
txt_path = 'MovementObservationName.txt'

def h5_to_csv(index):
    temp_name = '1week-Pair' + str(index) + 'DLC_dlcrnetms5_californiamouseMay31shuffle1_70000_el'
    current_file = os.getcwd() + '\\' + temp_name + '.h5'
    df = pd.read_hdf(current_file)
    df.dropna().to_csv(csv_path)
    
    with open(txt_path, 'w') as txt:
        txt.write(temp_name + '.xlsx')

def matlab_movement_analysis():
    eng = matlab.engine.start_matlab()
    eng.MiceMovementAnalysis(nargout=0)
    eng.quit()

if __name__ == '__main__':
    for i in range(1,25):
        h5_to_csv(i)
        matlab_movement_analysis()
        os.remove(csv_path)
        os.remove(txt_path)