#!/usr/bin/python3
import pandas as pd
import plotly.graph_objects as go
# Name of file with gofr data
gofrfile = 'gofr.dat'
# Name of file with boxsize
boxsize = 'box_size.dat'
# Number of molecules
Nmol = 22
# Mass per molecule in Da
mol_mass = 326.28209507
# Name of file for rhor output
rhorfile = 'rhor.dat'

box = pd.read_csv(
    boxsize,
    header=None,
    names=['x', 'y', 'z'],
    delimiter=r"\s+"
    )

box['volume'] = box['x'] * box['y'] * box['z']

box_vol = box['volume'].mean()

conv_factor = 1.6605E-27

avg_mass_dens = (Nmol * mol_mass * conv_factor) / (box_vol * 1E-30)

f = pd.read_csv(
    gofrfile,
    header=None,
    names=['bins', 'gofr', 'coordination_number'],
    delimiter=r"\s+"
    )

f['rhor'] = f['gofr'] * avg_mass_dens

fig_gofr = go.Figure()
fig_gofr.add_trace(go.Bar(
    x=f['bins'],
    y=f['gofr'],
    name="RM <i>g</i>(<i>r</i>)"
    )
)

fig_gofr.update_layout(
    font=dict(size=20),
    title='<i>g</i>(<i>r</i>)',
    xaxis_title=r'<i>r</i> \ Å',
    yaxis_title='<i>g</i>(<i>r</i>)',
    showlegend=True
    )
fig_gofr.update_xaxes(range=[0, 50])
fig_gofr.update_yaxes(range=[0, 0.005])
fig_gofr.write_html('fig_gofr.html')
fig_gofr.show()

fig_rhor = go.Figure()
fig_rhor.add_trace(go.Bar(
    x=f['bins'],
    y=f['rhor'],
    name="RM <i>ρ</i>(<i>r</i>)"
    )
)

fig_rhor.update_layout(
    font=dict(size=20),
    title='<i>ρ</i>(<i>r</i>)',
    xaxis_title=r'<i>r</i> \ Å',
    yaxis_title=r'<i>ρ</i>(<i>r</i>) \ kg.m<sup>-3</sup>',
    showlegend=True
    )
fig_rhor.update_xaxes(range=[0, 50])
fig_rhor.update_yaxes(range=[0, 0.2])
fig_rhor.write_html('fig_rhor.html')
fig_rhor.show()


f.to_csv(
    path_or_buf=rhorfile,
    sep=' ',
    columns=['bins', 'rhor'],
    header=False,
    index=False
    )
