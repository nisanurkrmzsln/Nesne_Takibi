clear; clc; close all;

%% 1. Kamera ve Grafik Ayarları
try
    cam = webcam(1); 
catch
    error('Web kamerası bulunamadı! Lütfen bağlantıyı kontrol edin.');
end

% Dashboard Figürü
hFig = figure('Name', 'Gelişmiş Telemetri ve Nesne Takip Sistemi', ...
              'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none');

% Güvenli Çıkış Butonu Ekleme
uicontrol('Style', 'pushbutton', 'String', 'Sistemi Güvenli Kapat', ...
          'Position', [20, 20, 150, 35], ...
          'Callback', 'setappdata(gcf, ''run'', false);', ...
          'BackgroundColor', [0.8 0.2 0.2], 'ForegroundColor', 'white', 'FontWeight', 'bold');
setappdata(hFig, 'run', true);

% Metrik Geçmişleri
maxHistory = 100;
x_history = zeros(1, maxHistory);
y_history = zeros(1, maxHistory);
speed_history = zeros(1, maxHistory); % Hız geçmişi dizisi
time_step = 1:maxHistory;

% İz bırakma (Trajectory) için son konum geçmişi
trajectoryLength = 15;
trajX = nan(1, trajectoryLength);
trajY = nan(1, trajectoryLength);

disp('Sistem başlatıldı. Gelişmiş metrik analizi aktif.');

%% 2. Gerçek Zamanlı İşleme Döngüsü
while getappdata(hFig, 'run') && ishandle(hFig)
    frame = snapshot(cam);
    frame = imresize(frame, 0.5); 
    [rows, cols, ~] = size(frame);
    
    % HSV Uzayına Geçiş
    hsvFrame = rgb2hsv(frame);
    H = hsvFrame(:,:,1); S = hsvFrame(:,:,2); V = hsvFrame(:,:,3);
    
    % Hassas Maskeler
    redMask = ((H < 0.02) | (H > 0.98)) & (S > 0.6) & (V > 0.4);
    blueMask = (H > 0.55) & (H < 0.70) & (S > 0.5) & (V > 0.4);
    combinedMask = redMask | blueMask;
    combinedMask = imopen(combinedMask, strel('disk', 7));
    
    %% 3. Koordinat ve Hız Hesaplama
    stats = regionprops(combinedMask, 'Centroid', 'Area');
    currentX = 0; currentY = 0;
    currentSpeed = 0;
    
    if ~isempty(stats)
        [~, maxIdx] = max([stats.Area]);
        centroid = stats(maxIdx).Centroid;
        currentX = centroid(1);
        currentY = centroid(2);
        
        % Hız Hesaplama: Bir önceki karedeki konum ile arasındaki Öklid Mesafesi
        prevX = x_history(end);
        prevY = y_history(end);
        if prevX ~= 0 && prevY ~= 0
            currentSpeed = sqrt((currentX - prevX)^2 + (currentY - prevY)^2);
        end
    end
    
    % Geçmiş Verileri Güncelle (Sola Kaydırma)
    x_history = [x_history(2:end), currentX];
    y_history = [y_history(2:end), currentY];
    speed_history = [speed_history(2:end), currentSpeed];
    
    % İz geçmişini güncelle
    if currentX ~= 0 && currentY ~= 0
        trajX = [trajX(2:end), currentX];
        trajY = [trajY(2:end), currentY];
    else
        % Nesne kaybolduysa izi yavaşça sıfırla
        trajX = [trajX(2:end), nan];
        trajY = [trajY(2:end), nan];
    end
    
    %% 4. Dashboard Çizimi
    % Ana Kamera Ekranı ve İz Takibi
    subplot(2, 2, [1, 3]);
    imshow(frame); hold on;
    if currentX ~= 0 && currentY ~= 0
        % Geçmiş izi çizdir (Kuyruk Efekti)
        plot(trajX, trajY, 'y-', 'LineWidth', 2); 
        % Güncel Konum
        plot(currentX, currentY, 'g+', 'MarkerSize', 18, 'LineWidth', 2.5);
        title(sprintf('HEDEF KİLİTLENDİ | Anlık Hız: %.1f px/frame', currentSpeed), 'Color', 'g', 'FontWeight', 'bold');
    else
        title('Hedef Aranıyor (Yüz/Deri Filtresi Aktif)...', 'Color', 'yellow');
    end
    hold off;
    
    % Sağ Üst Panel: Konum Grafikleri (X ve Y bir arada)
    subplot(2, 2, 2);
    plot(time_step, x_history, 'b', 'LineWidth', 1.2); hold on;
    plot(time_step, y_history, 'm', 'LineWidth', 1.2); hold off;
    ylabel('Piksel Değeri'); grid on; 
    ylim([0 max(rows, cols)]);
    legend('X (Yatay)', 'Y (Dikey)', 'Location', 'northwest');
    title('Telemetri: Konum Analizi');
    
    % Sağ Alt Panel: Hız Grafiği (Anlık Değişim)
    subplot(2, 2, 4);
    area(time_step, speed_history, 'FaceColor', [0.2 0.6 0.2], 'EdgeColor', 'g', 'FaceAlpha', 0.3);
    ylabel('Hız (px/frame)'); xlabel('Zaman (Kare)'); grid on;
    ylim([0 50]); % Hız ani sıçramaları için sınır
    title('Dinamik Hız Analizi');
    
    drawnow;
end

%% 5. Güvenli Kapatma Aşaması
if ishandle(hFig)
    close(hFig);
end
clear cam;
disp('Sistem ve kamera başarıyla kapatıldı.');