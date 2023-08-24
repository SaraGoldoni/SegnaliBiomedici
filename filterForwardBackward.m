
function data = filterForwardBackward(dati)
    G = 0.2; % per creare un filtro a guadagno unitario
    % coefficienti A e B dell'equazione alle differenze
    % Funzione di trasferimento H(z)=z^4+z^3+z^2+z+1/z^4
    B = [1 1 1 1 1];
    A = 1;
    data = filtfilt(G*B,A,dati);
    [H, F]=freqz(B,A,128);
    figure;
    plot(F,abs(H));
end 