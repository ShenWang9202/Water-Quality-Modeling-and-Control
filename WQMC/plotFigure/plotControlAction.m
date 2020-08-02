
figure
plot(ControlActionU)
legend(Location_B)
xlabel('Time (minute)')
ylabel('Mass at boosters (mg/minute)')

chlorinedose =  sum(sum(ControlActionU));
Price_Weight = Constants4Concentration.Price_Weight;
Price = chlorinedose* Price_Weight;
